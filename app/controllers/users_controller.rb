class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update, :destroy]
  before_action :set_active
  before_action :has_authority, except: [:info]
  skip_before_action :authorize, only: [:new, :create, :index]
  # GET /users
  def index
    @users = User.all
  end


  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # GET /users/1/info
  def info
    @user = User.find(params[:id])
    render json: Hash['id' => params[:id], 'talk_user_id' => @user.talk_user_id, 's_header' => @user.s_header].to_json
  end

  # POST /users
  def create
    begin
      ActiveRecord::Base.transaction do
        users = user_params[:email].split(",")
        users.each do | user |
          @user = User.new(email: user, authority: user_params[:authority])  
          @user.save
        end
      end
      redirect_to users_path, notice: 'User was successfully created.'
    rescue
      render :new
    end
    # if @user.save
    #   redirect_to users_path, notice: 'User was successfully created.'
    # else
    #   render :new
    # end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to users_path, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    redirect_to users_path, notice: 'User was successfully destroyed.'
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:email, :authority, :id)
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
