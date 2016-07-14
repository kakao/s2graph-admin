class AuthoritiesController < ApplicationController
  before_action :set_authority, only: [:edit, :update, :destroy]
  before_action :set_active
  before_action :has_authority

  # GET /users
  def index
    @authorities = Authority.joins(:user, :service).select("authorities.*, users.email, services.service_name")
# OR
  end

  # GET /authorities/new
  def new
    @authority = Authority.new
  end

  # GET /authorities/1/edit
  def edit
  end

  # POST /authorities
  def create
    @authority = Authority.new(authority_params)

    if @authority.save
      redirect_to authorities_url, notice: 'Authority was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /authorities/1
  def update
    if @authority.update(authority_params)
      redirect_to authorities_url, notice: 'Authority was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /authorities/1
  def destroy
    @authority.destroy
    redirect_to authorities_url, notice: 'Authority was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_authority
      @authority = Authority.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def authority_params
      params.require(:authority).permit(:user_id, :service_id)
    end

    def set_active
      @active = "admin"
    end

    def has_authority
      if session[:authority] != "master" then
        head :forbidden
      end
    end

end
