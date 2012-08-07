class HomeController < ApplicationController
  def index
    redirect_to search_path(:q=>params[:q]) if params[:q]
  end

  def site_plan
  end
end
