module Authenticator
  extend ActiveSupport::Concern

  included do
    if self.to_s != 'SessionController'
      before_action :require_user
    end

    helper_method :current_user
  end

  def require_user
    unless current_user
      store_location
      redirect_to root_path
      return false
    end
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end
