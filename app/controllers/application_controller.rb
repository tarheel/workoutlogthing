class ApplicationController < ActionController::Base

  protected

  def require_logged_in
    if !current_user
      redirect_to root_path
    end
  end
end
