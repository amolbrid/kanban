class SessionController < ApplicationController
  include Authenticator

  def new
    session.delete(:return_to)
    redirect_to boards_url if current_user
  end

  def create
    @user = User.find_or_create_from_auth_hash(auth_hash)
    session[:user_id] = @user.id
    redirect_back_or_default boards_url
  end

  def destroy
    session[:user_id] = nil
    session.delete(:return_to)
    redirect_to root_url
  end

  protected

    def auth_hash
      request.env['omniauth.auth']
    end
end
