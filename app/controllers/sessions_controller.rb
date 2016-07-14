class SessionsController < ApplicationController
  skip_before_action :authorize

  def new
  end

  def create
  	user = User.find_by(email: params[:email])

    auth_url = APP_CONFIG['auth_url']

    result = 'true'
    if auth_url.to_s != ''
      query = {username: params[:email], password: params[:password]}

      res = RestClient.post auth_url, query, :content_type => :json, :accept => :json
      parsed = (JSON.parse(res) rescue {}).with_indifferent_access
      result = parsed[:result]
    end  
  	
  	if user and result == "true"
  		session[:user_id] = user.id
      session[:authority] = user.authority
      
  		redirect_to s2ab_url
  	else
  		redirect_to login_url, alert:"Invalid Username or Password"
  	end
  end

  def destroy
  	session[:user_id] = nil
    session[:authority] = nil
  	redirect_to login_url, alert:"Succesfully logged out"
  end
end