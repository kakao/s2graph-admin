class BucketsController < ApplicationController
  include Util
  before_action :set_bucket, only: [:show, :edit, :update, :destroy, :copyBucket]
  before_action :set_active

  # GET /buckets/1
  def show
  end

  # GET /buckets/new
  def new
    @experiment_name = params.require(:name)
    @experiment_id = params.require(:id)
    @bucket = Bucket.new
    @graph_url = APP_CONFIG['s2graph_query_url']+'/graphs/getEdges'
  end

  # GET /buckets/1/edit
  def edit
    @experiment_name = Experiment.find(Bucket.find(params[:id]).experiment_id).name
    @experiment_id = Bucket.find(params[:id]).experiment_id
    @graph_url = APP_CONFIG['s2graph_query_url']+'/graphs/getEdges'
  end


  # POST /buckets
  def create
    bucket_params[:modular] = '0~0'
    @bucket = Bucket.new(bucket_params.merge({created_by: getUserName(session[:user_id])}))

    if @bucket.save
      redirect_to "/experiments/#{@bucket.experiment_id}/detail", notice: 'Bucket was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /buckets/1
  def update
    modular = bucket_params[:modular]
    if @bucket.update(bucket_params.merge({updated_by: getUserName(session[:user_id])}))
      redirect_to "/experiments/#{@bucket.experiment_id}/detail", notice: 'Bucket was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /buckets/1
  def destroy
    expId = @bucket.experiment_id
    @bucket.destroy
    redirect_to "/experiments/#{expId}/detail", notice: 'Bucket was successfully destroyed.'
  end


  # body = "abc: \"${-1day}\", def: \"${-1 hour}\" 'now': ${now} "
  # puts replace_variable(now, body)
  def replace_variable(now, body)
    regex = /"?\${(.*?)}"?/m
    num = /(next_day|next_hour|now)?\s*(-?\s*[0-9]+)?\s*(hour|day)?/

    hour = 60 * 60 * 1000
    day = hour * 24
    week = day * 7

    body.gsub(regex) do |m|
      #_pivot, n, unit = m.scan(num).flatten
      _pivot, n, unit = m.scan(num).reject { |a, b, c| a.nil? and b.nil? and c.nil? }.flatten

      logger.error "LOG:: => #{'*' * 80}"
      logger.error "LOG:: => #{m}"
      logger.error "LOG:: => #{_pivot}"
      logger.error "LOG:: => #{n}"
      logger.error "LOG:: => #{unit}"

      ts =
        if _pivot.nil?
          now
        elsif _pivot == "now"
          now
        elsif _pivot == "next_week"
          now / week * week + week
        elsif _pivot == "next_day"
          now / day * day + day
        elsif _pivot == "next_hour"
          now / hour * hour + hour
        end

      if _pivot.nil? and n.nil? and  unit.nil?
        m[0]
      elsif n.nil? or unit.nil?
        ts
      else
        if unit =~ /hour/i
          n.gsub(" ", "").to_i * hour + now
        elsif unit =~ /day/i
          n.gsub(" ", "").to_i * day + now
        elsif unit =~ /week/i
          n.gsub(" ", "").to_i * weak + now
        end
      end
    end
  end

  # POST /buckets/validate_request_body
  def validateRequestBody
    api_path = params[:api_path].gsub(/\s+/, "")
    query = params[:body]
    # query = replace_variable(Time.now.to_i * 1000, query)
    puts query

    begin
      res = RestClient.post api_path, query, :content_type => :json, :accept => :json
      parsed = JSON.parse(res) rescue {}

      result = Hash["status" => "success", "results" => parsed.to_json]
      render json: result.to_json
    rescue
      result = Hash["status" => "fail", "results" => "http request errror."]
      render json: result.to_json
    end

  end

  def getCopyBucketImpressionID(impressionId)
    existBucket = Bucket.where(impression_id: impressionId).take
    if existBucket.nil?
      return impressionId
    else
      getCopyBucketImpressionID(impressionId+ '_c')
    end
  end

  #PUT /buckets/1/copy_bucket
  def copyBucket
    # experiment_id
    # http_verb
    # api_path
    # request_body
    # timeout
    # impression_id
    # modular
    # is_graph_query
    # is_empty
    anotherBucket = Bucket.new(experiment_id: @bucket.experiment_id, http_verb: @bucket.http_verb,
                               api_path: @bucket.api_path, request_body: @bucket.request_body,
                               timeout: @bucket.timeout, impression_id: @bucket.impression_id,
                               modular: '0~0', is_graph_query: @bucket.is_graph_query, is_empty: @bucket.is_empty)
    anotherBucket.impression_id = getCopyBucketImpressionID(anotherBucket.impression_id + '_c')

    if anotherBucket.save
      result = Hash["status" => "success", "results" => "bucket copy success."]
      render json: result.to_json
    else
      result = Hash["status" => "fail", "results" => "bucket copy fail."]
      render json: result.to_json
    end

  end

  # GET /labels/check/s2graph_label
  def check
    impression_id = params["impression_id"]
    bucket = Bucket.where(impression_id: impression_id).take
    if bucket.nil?
      result = Hash["isAlreadyExist" => "false"]
      render json: result.to_json
    else
      result = Hash["isAlreadyExist" => "true"]
      render json: result.to_json
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_bucket
    @bucket = Bucket.find(params[:id])
    has_authority
  end

  def has_authority
    user = User.find(session[:user_id])
    if user.authority != "master" then
      experiment = Experiment.find(@bucket.experiment_id)
      authorities = Authority.where(user_id: session[:user_id], service_id: experiment.service_id)
      if authorities.size <= 0 then
        render status: 550
      end
    end
  end

  # Only allow a trusted parameter "white list" through.
  def bucket_params
    params.require(:bucket).permit(:experiment_id, :http_verb, :api_path, :uuid_key, :uuid_placeholder, :request_body, :timeout, :impression_id, :is_graph_query, :modular, :is_empty, :description, :variables)
  end

  def set_active
    @active = "s2ab"
  end
end
