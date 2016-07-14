# coding: utf-8
class ExperimentsController < ApplicationController
  include Util
  before_action :set_experiment, only: [:show, :edit, :update, :destroy, :ctr, :detail]
  before_action :set_active
  skip_before_filter :authorize, only: [:ratioUpdateAll]
  skip_before_filter :verify_authenticity_token, only: [:ratioUpdateAll]

  # GET /experiments/
  def index
    # @experiments = Experiment.includes(:buckets)

    # exps = Experiment.includes(:service => [:authorities => [{ :user => session[:user_id]}]])
    user = User.find(session[:user_id])
    @exps = nil
    if user.authority == 'master' then
      @exps = Experiment.all.order(:service_name)
    else
      authorities = Authority.where(user_id: session[:user_id]).select("service_id")
      @exps = Experiment.where(service_id: authorities).order(:service_name)
    end

    @experiments_hash = {}
    for exp in @exps
      if @experiments_hash[exp.service_name].nil?
        @experiments_hash[exp.service_name] = []
      end
      @experiments_hash[exp.service_name].push(exp)
    end

  end

  # GET /experiments/1
  def show
  end

  #POST /experiments/1/modular
  def modular

    paramsToUpdate = params.except(:controller, :action, :id)
    keys = paramsToUpdate.keys
    values = paramsToUpdate.values.map do |value|
      Hash["modular" => value]
    end

    if Bucket.update(keys, values)
      result = Hash["status" => "success"]
      render json: result.to_json
    else
      result = Hash["status" => "fail"]
      render json: result.to_json
    end
  end

  #GET s2ab/:access_token/list/:experiment_name
  def list
    access_token = params[:access_token]
    experiment_name = params[:experiment_name]
    if experiment_name.nil?
      serviceId = Service.where(access_token: access_token).take.id
      experiments = Experiment.where(service_id: serviceId)
      exps = experiments.map do | experiment |
        experimentId = experiment.id
        experiment = experiment.as_json.merge({buckets: Bucket.where(experiment_id: experimentId)})
      end
      render json: exps.to_json
    else
      serviceId = Service.where(access_token: access_token).take.id
      experiments = Experiment.where(service_id: serviceId, name: experiment_name)
      exps = experiments.map do | experiment |
        experimentId = experiment.id
        experiment = experiment.as_json.merge({buckets: Bucket.where(experiment_id: experimentId)})
      end
      render json: exps.to_json
    end
    
  end

  
  #POST s2ab/:access_token/ratio-update-all
  def ratioUpdateAll
    begin
      access_token = params[:access_token]
      service = Service.where(access_token: access_token).take
      if service.nil?
        render_result("fail", "Invalid access_token.")
      end
      experiment = Experiment.where(service_id: service.id, name: params[:test_name]).take

      if experiment.nil?
        render_result("fail", "There is no experiment.")
      end

      buckets = Bucket.where(experiment_id: experiment.id)
      if (buckets.nil? || buckets.size == 0)
        render_result("fail", "There is no bucket.")
      end

      ratios = params[:ratios]

      keys ||= Array.new
      values ||= Array.new
      ratios.each do |ratio|
        bucket = buckets.where(impression_id: ratio[:impression_id]).take
        keys.push(bucket[:id])
        values.push(Hash["modular" => ratio[:ratio]])
      end

      if (ratios.size == keys.size && keys.size == values.size)
        if Bucket.update(keys, values)
          render_result("success", "Ratios is updated.")
        else
          render_result("fail", "DB error.")
        end
      else
        render_result("fail", "Invalid json format.")
      end
    rescue
      render_result("fail", "Invalid json format.")
    end
  end


  # GET /experiments/1/detail
  def detail
    @experiments = Experiment.includes(:buckets).where("id = ?", @experiment.id)

    experiment = Experiment.find(@experiment.id)

    @access_token = Service.find(experiment.service_id).access_token
    # logger.error("===================")
    # logger.error( @experiment.buckets.joins("LEFT JOIN users ON (users.id = 'updated_by')").select("buckets.*, users.email as update_by_email").to_json)

    # logger.error("===================")
    @service, @buckets = @experiment.service, @experiment.buckets.order(:impression_id)
    action_types = @experiment.action_types
    @action_types_for_view = action_types.map { |a| [a, a] }

    # from params[:xx]
    @from, @to = params.values_at(:from_time, :to_time)
    @time_units = [:H, :d]
    @time_unit = params.fetch(:time_unit, :d).to_sym

    if @time_unit == :H
      from = (@from ? (DateTime.parse(@from).beginning_of_day).to_i : (Time.now.beginning_of_day - 1.days).to_i) * 1000
      to = (@to ? (DateTime.parse(@to).end_of_day).to_i : (Time.now.end_of_day).to_i) * 1000
    else
       from = (@from ? (DateTime.parse(@from)).to_i : (Time.now - 14.days).to_i) * 1000
      to = (@to ? (DateTime.parse(@to)).to_i : (Time.now).to_i) * 1000
    end

    @from = Time.at(from/1000).strftime("%Y-%m-%d") if @from.nil?
    @to = Time.at(to/1000).strftime("%Y-%m-%d") if @to.nil?

    @nom = params.fetch(:nom, action_types.first)
    @denom = params.fetch(:denom, action_types.last)

    @chart_data = @experiment.make_chart(@nom, @denom, @time_unit, from, to)

    respond_to do |format|
      format.html
      format.json { render json: @chart_data }
    end

  end

  # GET /experiments/new
  def new
    @experiment = Experiment.new
  end

  # GET /experiments/1/edit
  def edit
  end

  # POST /experiments
  def create
    @experiment = Experiment.new(experiment_params.merge({created_by: getUserName(session[:user_id])}))

    if @experiment.save
      redirect_to s2ab_path, notice: 'Test was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /experiments/1
  def update
    if @experiment.update(experiment_params.merge({updated_by: getUserName(session[:user_id])}))
      redirect_to s2ab_path, notice: 'Test was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /experiments/1
  def destroy
    @experiment.destroy
    redirect_to s2ab_path, notice: 'Test was successfully destroyed.'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
    def render_result(status, msg)
      result = Hash["status" => status, "msg" => msg]
      render json: result.to_json
    end

    def set_experiment
      @experiment = Experiment.find(params[:id])
      has_authority
    end

    def has_authority
      user = User.find(session[:user_id])
      if user.authority != "master" then
        authorities = Authority.where(user_id: session[:user_id], service_id: @experiment.service_id)
        if authorities.size <= 0
          raise "error"
        end
      end
    end

    # Only allow a trusted parameter "white list" through.
    def experiment_params
      @service = Service.find(params[:experiment][:service_id])
      @service_name = @service.service_name
      params[:experiment][:service_name] = @service_name
      params.require(:experiment).permit(:service_id, :service_name, :name, :description, :experiment_type, :total_modular)
    end

    def set_active
      @active = "s2ab"
    end
end
