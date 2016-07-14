require 'labels_controller'
class CountersController < ApplicationController
  before_action :set_counter, only: [:show, :edit, :update, :destroy]
  before_action :set_active

  class LabelNotFoundError < StandardError
  end

  class LabelAlreadyExistError < StandardError
  end

  class LabelCreateError < StandardError
  end

  # GET /counters
  def index
    @counters = Counter.all
  end

  # GET /counters/1
  def show
  end

  # GET /counters/new
  def new
    @version = 2
    @counter = Counter.new
  end

  # GET /counters/1/edit
  def edit
    @version = @counter.version
  end

  def create_label_on_s2graph(label, service_id, label_name,
                              src_service_id, src_column_name, src_column_type,
                              tgt_service_id, tgt_column_name, tgt_column_type,
                              hbase_table_ttl,
                              properties, indices)
    is_directed = 1
    consistency_level = 'weak'

    hbase_table_name = @counter.hbase_table
    schema_version = label.schema_version
    is_async = 0
    compression_algorithm = APP_CONFIG['compression_algorithm']

    begin
      LabelsController.createLabel(service_id, label_name,
                                   src_service_id, src_column_name, src_column_type,
                                   tgt_service_id, tgt_column_name, tgt_column_type,
                                   is_directed, consistency_level,
                                   hbase_table_name, hbase_table_ttl, schema_version, is_async, compression_algorithm,
                                   properties, indices)
    rescue => e
      logger.error(e)
      raise LabelCreateError
    end
  end

  def create_ranking_counter(counter_params)
    action = @counter.action
    label = Label.where(label: action).take
    unless counter_params[:rate_action_id].blank?
      rate_counter = Counter.find(counter_params[:rate_action_id])
      label = Label.where(label: rate_counter.action).take
    end
    raise LabelNotFoundError if label.nil? # action 이름으로 라벨이 없으면 error

    counter_label_name = action + '_topK'
    counter_label = Label.where(label: counter_label_name).take

    raise LabelAlreadyExistError unless counter_label.nil? # 카운터 라벨이 있으면 error

    counter_service = Service.where(service_name: 's2counter').take

    src_service_id = counter_service.id
    src_column_name = 'bucket'
    src_column_type = 'string'

    tgt_service_id = label.tgt_service_id
    tgt_column_name = label.tgt_column_name
    tgt_column_type = label.tgt_column_type

    properties = "[{\"PROPERTY NAME\":\"time_unit\",\"SEQ\":\"1\",\"PROPERTY TYPE\":\"string\",\"DEFAULT VALUE\":\"\"},{\"PROPERTY NAME\":\"time_value\",\"SEQ\":\"2\",\"PROPERTY TYPE\":\"long\",\"DEFAULT VALUE\":\"\"},{\"PROPERTY NAME\":\"date_time\",\"SEQ\":\"3\",\"PROPERTY TYPE\":\"long\",\"DEFAULT VALUE\":\"\"},{\"PROPERTY NAME\":\"score\",\"SEQ\":\"4\",\"PROPERTY TYPE\":\"float\",\"DEFAULT VALUE\":\"\"}]"
    indices = "[{\"INDEX NAME\":\"time\",\"SEQ\":\"1\",\"META SEQ\":\"1,2,4\"}]"

    hbase_table_ttl = nil
    unless @counter.daily_ttl.blank?
      hbase_table_ttl = @counter.daily_ttl * 24 * 3600
    end

    create_label_on_s2graph(label, label.tgt_service_id, counter_label_name,
                            src_service_id, src_column_name, src_column_type,
                            tgt_service_id, tgt_column_name, tgt_column_type,
                            hbase_table_ttl,
                            properties, indices)
  end

  # POST /counters
  def create
    Counter.transaction do
      @counter = Counter.new(counter_params)
      temp_label = Label.where(label: @counter.action).take
      raise ActiveRecord::RecordNotFound if temp_label.nil? # action 이름으로 라벨이 없으면 error
      @counter.item_type = case temp_label.tgt_column_type
                             when 'integer' then 0
                             when 'long' then 1
                             when 'string' then 2
                             else
                               # type code here
                               raise ActiveRecord::ActiveRecordError
                           end

      htable_table_name_array = ['s2counter', 'v2', temp_label.service_name]

      hbase_table_ttl = nil
      unless @counter.daily_ttl.blank?
        htable_table_name_array.push(@counter.daily_ttl)

        hbase_table_ttl = @counter.daily_ttl * 24 * 3600
      end
      hbase_table_name = htable_table_name_array.join('_')

      @counter.hbase_table = hbase_table_name


      if @counter.save
        action = counter_params[:action]
        label = Label.where(label: action).take
        if counter_params[:rate_action_id].blank?
          # make exact counter label
          raise LabelNotFoundError if label.nil? # action 이름으로 라벨이 없으면 error

          counter_label_name = action + '_counts'
          counter_label = Label.where(label: counter_label_name).take

          raise LabelAlreadyExistError unless counter_label.nil? # 카운터 라벨이 있으면 error

          counter_service = Service.where(service_name: 's2counter').take

          src_service_id = label.tgt_service_id
          src_column_name = label.tgt_column_name
          src_column_type = label.tgt_column_type

          tgt_service_id = counter_service.id
          tgt_column_name = 'bucket'
          tgt_column_type = 'string'

          properties = "[{\"PROPERTY NAME\":\"time_unit\",\"SEQ\":\"1\",\"PROPERTY TYPE\":\"string\",\"DEFAULT VALUE\":\"\"},{\"PROPERTY NAME\":\"time_value\",\"SEQ\":\"2\",\"PROPERTY TYPE\":\"long\",\"DEFAULT VALUE\":\"0\"}]"
          indices = "[{\"INDEX NAME\":\"time\",\"SEQ\":\"1\",\"META SEQ\":\"-5,1,2\"}]"

          create_label_on_s2graph(label, label.tgt_service_id, counter_label_name,
                                  src_service_id, src_column_name, src_column_type,
                                  tgt_service_id, tgt_column_name, tgt_column_type,
                                  hbase_table_ttl,
                                  properties, indices)
        end

        if counter_params[:use_rank] == '1' || !counter_params[:rate_action_id].blank?
          # make ranking counter
          unless counter_params[:rate_action_id].blank?
            counter = Counter.find(counter_params[:rate_action_id])
            label = Label.where(label: counter.action).take
          end
          raise LabelNotFoundError if label.nil? # action 이름으로 라벨이 없으면 error

          counter_label_name = action + '_topK'
          counter_label = Label.where(label: counter_label_name).take

          raise LabelAlreadyExistError unless counter_label.nil? # 카운터 라벨이 있으면 error

          counter_service = Service.where(service_name: 's2counter').take

          src_service_id = counter_service.id
          src_column_name = 'bucket'
          src_column_type = 'string'

          tgt_service_id = label.tgt_service_id
          tgt_column_name = label.tgt_column_name
          tgt_column_type = label.tgt_column_type

          properties = "[{\"PROPERTY NAME\":\"time_unit\",\"SEQ\":\"1\",\"PROPERTY TYPE\":\"string\",\"DEFAULT VALUE\":\"\"},{\"PROPERTY NAME\":\"time_value\",\"SEQ\":\"2\",\"PROPERTY TYPE\":\"long\",\"DEFAULT VALUE\":\"\"},{\"PROPERTY NAME\":\"date_time\",\"SEQ\":\"3\",\"PROPERTY TYPE\":\"long\",\"DEFAULT VALUE\":\"\"},{\"PROPERTY NAME\":\"score\",\"SEQ\":\"4\",\"PROPERTY TYPE\":\"float\",\"DEFAULT VALUE\":\"\"}]"
          indices = "[{\"INDEX NAME\":\"time\",\"SEQ\":\"1\",\"META SEQ\":\"1,2,4\"}]"

          create_label_on_s2graph(label, label.tgt_service_id, counter_label_name,
                                  src_service_id, src_column_name, src_column_type,
                                  tgt_service_id, tgt_column_name, tgt_column_type,
                                  hbase_table_ttl,
                                  properties, indices)
        end
        redirect_to @counter, notice: 'Counter was successfully created.'
      else
        render :new
      end
    end
  end

  # PATCH/PUT /counters/1
  def update
    if !@counter.use_rank and counter_params[:use_rank] == '1'
      # create ranking counter
      begin
        create_ranking_counter(counter_params)
      rescue LabelAlreadyExistError
        # ignored
      end
    end
    if @counter.update(counter_params)
      redirect_to @counter, notice: 'Counter was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /counters/1
  def destroy
    @counter.destroy
    redirect_to counters_url, notice: 'Counter was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_active
      @active = 'counter'
    end

    def set_counter
      @counter = Counter.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def counter_params
      params.require(:counter).permit(:id, :use_flag, :version, :service, :action, :item_type, :auto_comb, :dimension, :use_profile, :bucket_imp_id, :use_exact, :use_rank, :ttl, :daily_ttl, :hbase_table, :interval_unit, :rate_action_id, :rate_base_id, :rate_threshold)
    end
end
