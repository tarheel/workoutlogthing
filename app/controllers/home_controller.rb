class HomeController < ApplicationController
  def index
    if current_user
      render 'index_logged_in'
    else
      render 'index_logged_out'
    end
  end
end
