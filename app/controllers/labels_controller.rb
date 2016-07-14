# coding: utf-8
require 'htable'
class LabelsController < ApplicationController
  before_action :set_label, only: [:show, :edit, :update, :destroy, :addPropsAndIndices]
  before_action :set_active
  skip_before_filter :authorize, only: [:check]

  class SourceColumnCreateError < StandardError
  end
  class TargetColumnCreateError < StandardError
  end
  class LabelAlreadyExist < StandardError
  end
  class PropertyAlreadyExist < StandardError
  end
  class IndexAlreadyExist < StandardError
  end


  # GET /labels
  def index
    user = User.find(session[:user_id])
    @authority = user.authority
    if @authority == 'master'
      @labels = Label.all
    else
      head :forbidden
    end
  end

  # GET /labels/1
  def show

  end

  # GET /labels/new
  def new
    id = params[:id]
    if !id.nil?
      @selected_service_name = Service.find(id).service_name
      @service_htable_name = Service.find(id).hbase_table_name
    end
    @label = Label.new
  end

  # GET /labels/1/edit
  def edit
    @hbase_table_name = @label.hbase_table_name
    @metas = LabelMetum.where(label_id: @label.id).order(id: :asc)
    @indices = LabelIndex.where(label_id: @label.id).order(id: :asc)
  end

  # GET /labels/check/s2graph_label
  def check
    label_name = params["label_name"]
    label = Label.where(label: label_name).take
    if label.nil?
      result = Hash["isAlreadyExist" => "false"]
      render json: result.to_json
    else
      result = Hash["isAlreadyExist" => "true"]
      render json: result.to_json
    end
  end

  # POST /labels
  def create

    service_id = label_params[:service_id]
    service = Service.find(service_id)
    service_name = service.service_name
    cluster = service.cluster

    label_name = label_params[:label]

    src_service_id = label_params[:src_service_id]
    src_column_name = label_params[:src_column_name]
    src_column_type = label_params[:src_column_type]

    tgt_service_id = label_params[:tgt_service_id]
    tgt_column_name = label_params[:tgt_column_name]
    tgt_column_type = label_params[:tgt_column_type]


    is_directed = label_params[:is_directed]
    consistency_level = label_params[:consistency_level]
    hbase_table_name = label_params[:hbase_table_name]
    hbase_table_ttl = label_params[:hbase_table_ttl] == nil ? service.hbase_table_ttl : label_params[:hbase_table_ttl]
    schema_version = label_params[:schema_version]
    is_async = label_params[:is_async]
    compressionAlgorithm = label_params[:compressionAlgorithm].nil? ? 'lz4' : label_params[:compressionAlgorithm]

    properties = label_params[:properties]
    indices = label_params[:indices]

    begin
      LabelsController.createLabel(service_id, label_name,
                        src_service_id, src_column_name, src_column_type,
                        tgt_service_id, tgt_column_name, tgt_column_type,
                        is_directed, consistency_level,
                        hbase_table_name, hbase_table_ttl, schema_version, is_async, compressionAlgorithm,
                        properties, indices)

    rescue ActiveRecord::RecordNotFound => e
      logger.error("Record not found. : #{e}")
      render_result("fail", "Record not found.")
    rescue SourceColumnCreateError => e
      logger.error("Source column create error. : #{e}")
      render_result("fail", "Source column create error.")
    rescue TargetColumnCreateError => e
      logger.error("Target column create error. : #{e}")
      render_result("fail", "Target column create error.")
    rescue LabelAlreadyExist => e
      logger.error("Label already exist. : #{e}")
      render_result("fail", "Label already exist.")
    rescue PropertyAlreadyExist => e
      logger.error("Property already exist. : #{e}")
      render_result("fail", "Property already exist.")
    rescue IndexAlreadyExist => e
      logger.error("Index already exist. : #{e}")
      render_result("fail", "Index already exist.")
    rescue HTable::HTableNameNotFound => e
      logger.error("Htable name not found. : #{e}")
      render_result("fail", "Htable name not found.")
    rescue HTable::HTableCreateError => e
      logger.error("Htable create error. : #{e}")
      render_result("fail", "Htable create error.")
    rescue => e
      render_result("fail", "Create label error. : #{e}")
    else
      render_result("success", "Label was created.")
    end
  end

  def self.createLabel(service_id, label_name,
                        src_service_id, src_column_name, src_column_type,
                        tgt_service_id, tgt_column_name, tgt_column_type,
                        is_directed, consistency_level,
                        hbase_table_name, hbase_table_ttl, schema_version, is_async, compressionAlgorithm,
                        properties, indices)
    service = Service.find(service_id)
    service_name = service.service_name
    cluster = service.cluster

    # source column 생성
    srcSc = LabelsController.service_column_find_or_insert(src_service_id, src_column_name, src_column_type, schema_version)
    if (srcSc.nil? || srcSc.column_type != src_column_type)
      # throw exception
      raise SourceColumnCreateError
    end
    # target column 생성
    tgtSc = LabelsController.service_column_find_or_insert(tgt_service_id, tgt_column_name, tgt_column_type, schema_version)
    if (tgtSc.nil? || tgtSc.column_type != tgt_column_type)
      # throw exception
      raise TargetColumnCreateError
    end

    ActiveRecord::Base.transaction do
      label = Label.where(label: label_name).take
      raise LabelAlreadyExist if !label.nil?
      # 새 라벨 생성
      # hbase table name 이 없으면 service의 hbase table name 사용
      hbase_table_name = (hbase_table_name.nil? || hbase_table_name == "") ? service.hbase_table_name : hbase_table_name

      label = Label.new(label: label_name, src_service_id: src_service_id, src_column_name: src_column_name, src_column_type: src_column_type,
        tgt_service_id: tgt_service_id, tgt_column_name: tgt_column_name, tgt_column_type: tgt_column_type,
        is_directed: is_directed, service_name: service_name, service_id: service_id, consistency_level: consistency_level,
        hbase_table_name: hbase_table_name, hbase_table_ttl: hbase_table_ttl, schema_version: schema_version, is_async: is_async, compressionAlgorithm: compressionAlgorithm)

      label.save!
      labelId = label.id

      LabelsController.addProps(labelId, properties)
      LabelsController.addIndices(labelId, indices, false)

      raise HTable::HTableNameNotFound if hbase_table_name.nil?

      hbase_table_ttl = hbase_table_ttl.nil? ? service.hbase_table_ttl : hbase_table_ttl
      result = HTable.createTable(cluster, hbase_table_name, service.pre_split_size, hbase_table_ttl, compressionAlgorithm)
      logger.error(result)

      raise HTable::HTableCreateError if result == false
    end # transaction end
  end

  def self.addProps(labelId, properties)

    LabelMetum.transaction do
      JSON.parse(properties).each do |property|
        propertyName = property["PROPERTY NAME"]
        existProp = LabelMetum.where(label_id: labelId, name: propertyName).take
        if (existProp.nil?)
          propertyType = property["PROPERTY TYPE"]
          seq = property["SEQ"]
          defaultValue = case propertyType
            when "string" then ""
            when "integer" then 0
            when "long" then 0
            when "float" then 0.0
            when "boolean" then false
          end

          if (!property["DEFAULT VALUE"].nil? && property["DEFAULT VALUE"] != "")
            defaultValue = property["DEFAULT VALUE"]
          end

          labelMeta = LabelMetum.new(label_id: labelId, name: propertyName, seq: seq, default_value: defaultValue, data_type: propertyType)
          labelMeta.save!
        end
      end
    end
  end

  def self.addIndices(labelId, indices, isModifyMode)
    #insert indices
    LabelIndex.transaction do
      indices = JSON.parse(indices)
      if (indices.size > 0 )
        indices.each do |index|
          indexName = index["INDEX NAME"]
          seq = index["SEQ"]
          metaSeqs= index["META SEQ"]
          existIndex = LabelIndex.where(label_id: labelId, name: indexName, seq: seq, meta_seqs: metaSeqs).take
          if existIndex.nil?
            labelIndex = LabelIndex.new(name: indexName, label_id: labelId, seq: seq, meta_seqs: metaSeqs, formulars: "none")
            labelIndex.save!
          end
        end
      else
        # 인덱스 없는 경우
        # _PK timestamp 0
        if (!isModifyMode)
          labelIndex = LabelIndex.new(name: "_PK", label_id: labelId, seq: 1, meta_seqs: 0, formulars: "none")
          labelIndex.save
        end
      end
    end
  end

  def addPropsAndIndices

    logger.error(label_params)
    labelId = params[:id]

    properties = label_params[:properties]
    indices = label_params[:indices]
    hbase_table_name = label_params[:hbase_table_name]

    logger.error(label_params)
    begin
      ActiveRecord::Base.transaction do
        @label.update(is_async: label_params[:is_async], hbase_table_name: hbase_table_name)
        LabelsController.addProps(labelId, properties)
        LabelsController.addIndices(labelId, indices, true)
      end
    rescue ActiveRecord::RecordNotFound => e
      render_result("fail", "adding props&indices is failed. : #{e}")
    rescue => e
      render_result("fail", "adding props&indices is failed. : #{e}")
    else
      render_result("success", "props&indices are added.")
    end

  end

  # DELETE /labels/1

  def destroy
    @label.destroy
    redirect_to labels_url, notice: 'Label was successfully destroyed.'
  end

  private

    def render_result(status, message)
      result = Hash["status" => status, "message" => message]
      render json: result.to_json
    end

    def self.service_column_find_or_insert(service_id, column_name, column_type, schema_version)
      sc = ServiceColumn.where(service_id: service_id, column_name: column_name ).take
      if (sc.nil?)
        sc = ServiceColumn.new(service_id: service_id, column_name: column_name, column_type: column_type, schema_version: schema_version)
        if sc.save
          return sc
        else
          return nil
        end
      else
        return sc
      end
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_label
      @label = Label.find(params[:id])
      has_authority
    end

    def has_authority
      user = User.find(session[:user_id])
      @authority = user.authority
      if @authority != "master" then
        authorities = Authority.where(user_id: session[:user_id], service_id: @label.service_id)
        if authorities.size <= 0
          head :forbidden
        end
      end
    end

    # Only allow a trusted parameter "white list" through.
    def label_params
      #Logger.error(params)
      #Logger.error(params[:label])
      params.require(:label).permit(:label, :src_service_id, :src_column_name, :src_column_type, :tgt_service_id, :tgt_column_name, :tgt_column_type, :is_directed, :service_id, :consistency_level, :hbase_table_name, :hbase_table_ttl, :schema_version, :is_async, :compressionAlgorithm, :properties, :indices)
      #params[:src_name_tgt] = params[:src_name]
    end

    def set_active
      @active = "s2graph"
    end
end
