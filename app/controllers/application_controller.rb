class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :team_password])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def require_logged_in
    if !current_user
      redirect_to root_path
    end
  end
end
