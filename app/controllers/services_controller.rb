require 'htable'
class ServicesController < ApplicationController

  before_action :set_service, only: [:show, :edit, :update, :destroy, :updateAccessToken]
  before_action :set_active

  # GET /services
  def index
    user = User.find(session[:user_id])
    @authority = user.authority
    if @authority == 'master'
      @services = Service.all.order(:service_name)
    else
      authorities = Authority.where(user_id: session[:user_id]).select("service_id")
      @services = Service.where(id: authorities).order(:service_name)
    end
  end

  # GET /services/1
  def show
    # @service_columns = ServiceColumn.joins(:column_metas).where(service_id: @service.id).select("service_columns.*, column_metas.*")
    @service_columns = ServiceColumn.joins('LEFT OUTER JOIN column_metas ON column_metas.column_id = service_columns.id')
    .where(service_id: @service.id)
    .select("service_columns.*, column_metas.id as meta_id, column_metas.name, column_metas.column_id, column_metas.seq, column_metas.data_type")

    @labels = Label.where(service_id: @service.id)
    createService = {"serviceName" => @service.service_name, "hTableName" => @service.hbase_table_name, "preSplitSize" => @service.pre_split_size}
    if @service.hbase_table_ttl != nil
      createService["hTableTTL"] = @service.hbase_table_ttl
    end
    createServiceCURL = "curl -XPOST localhost:9000/graphs/createService -H 'Content-Type: Application/json' -d '\n#{JSON.pretty_generate(createService)}\n'"
    @createCURLs = createServiceCURL
    @labels.each do | label |
      # curl -XPOST localhost:9000/graphs/createLabel -H 'Content-Type: Application/json' -d '
      # {
      #     "label": "user_article_liked",
      #     "srcServiceName": "s2graph",
      #     "srcColumnName": "user_id",
      #     "srcColumnType": "long",
      #     "tgtServiceName": "s2graph_news",
      #     "tgtColumnName": "article_id",
      #     "tgtColumnType": "string",
      #     "indices": [], // _timestamp will be used as default
      #     "props": [],
      #     "serviceName": "s2graph_news"
      # }
      # '
      labelPostfix = label.label.split("_").last
      next if (labelPostfix == "counts" || labelPostfix == "topK")
      labelMetas = LabelMetum.where(label_id: label.id)
      labelIndices = LabelIndex.where(label_id: label.id).order(seq: :asc)

      props = labelMetas.map do | meta |
        {"name" => meta.name, "defaultValue" => meta.default_value, "dataType" => meta.data_type}
      end


      indices = labelIndices.map do | index |
        logger.error(index.meta_seqs)
        prop_names = index.meta_seqs.split(",").map do |meta_seq|
          meta_seq = meta_seq.to_i
          if meta_seq == 0
            "_timestamp"
          elsif meta_seq == -5
            "_to"
          else
            labelMetas.where(seq: meta_seq).first.name
          end
        end
        {"name" => index.name, "propNames" => prop_names}
      end
      createLabel = {"label" => label.label, "srcServiceName" => Service.find(label.src_service_id).service_name, "srcColumnName" => label.src_column_name, "srcColumnType" => label.src_column_type,
      "srcServiceName" => Service.find(label.src_service_id).service_name, "srcColumnName" => label.src_column_name, "srcColumnType" => label.src_column_type,
      "indices" => indices, "props" => props, "serviceName" => Service.find(label.service_id).service_name,
      "consistencyLevel" => label.consistency_level, "hTableName" => label.hbase_table_name}
      if label.is_directed == 1
        createLabel["isDirected"] = "true"
      else
        createLabel["isDirected"] = "false"
      end

      if label.hbase_table_ttl != nil
        createLabel["hTableTTL"] = label.hbase_table_ttl
      end

      createLabelCURL = "curl -XPOST localhost:9000/graphs/createLabel -H 'Content-Type: Application/json' -d '\n#{JSON.pretty_generate(createLabel)}\n'"
      @createCURLs = @createCURLs + "\n\n" + createLabelCURL
    end
    
  end

  # GET /services/new
  def new
    user = User.find(session[:user_id])
    @authority = user.authority
    if @authority != "master" then
      head :forbidden
    else
      @service = Service.new
    end
  end

  # GET /services/1/edit
  def edit
  end

  # POST /services
  def create
    @service = Service.new(service_params)

    result = HTable.createTable(@service.cluster, @service.hbase_table_name, @service.pre_split_size, @service.hbase_table_ttl, nil)
    if result
      if @service.save
        redirect_to services_url, notice: 'Service was successfully created.'
      else
        render :new
      end
    else
      render :new
    end
  end

  # PATCH/PUT /services/1
  def update
    if @service.update(service_params)
      redirect_to @service, notice: 'Service was successfully updated.'
    else
      render :edit
    end
  end

  def updateAccessToken
    if @service.update(access_token: params[:access_token])
      result = Hash["status" => "success"]
      render json: result.to_json
    else
      result = Hash["status" => "fail"]
      render json: result.to_json
    end
  end


  # DELETE /services/1
  def destroy
    @service.destroy
    redirect_to services_url, notice: 'Service was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service
      @service = Service.find(params[:id])
      has_authority
    end

    def has_authority
      user = User.find(session[:user_id])
      @authority = user.authority
      if @authority != "master" then
        authorities = Authority.where(user_id: session[:user_id], service_id: @service.id)
        if authorities.size <= 0
          head :forbidden
        end
      end
    end

    # Only allow a trusted parameter "white list" through.
    def service_params
      params.require(:service).permit(:service_name, :access_token, :cluster, :hbase_table_name, :pre_split_size, :hbase_table_ttl)
    end

    def set_active
      @active = "s2graph"
    end
end
