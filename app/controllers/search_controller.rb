class SearchController < ApplicationController
  def index
    unless params[:q]
      redirect_to root_path
    else
      # TODO: Add an index on name to enable sorting on huge number of artists
      @artists = Artist.queried(params[:q]).order_by([:name, :asc]).page(params[:page]) 
      # TODO: Add an index on title to enable sorting on huge number of works
      @works = Work.queried(params[:q]).order_by([:title, :asc]).page(params[:page])
      # TODO: Add an index on title to enable sorting on huge number of recordings
      @recordings = Recording.queried(params[:q]).order_by([:title, :asc]).page(params[:page])
      # TODO: Add an index on title to enable sorting on huge number of albums
      @albums = Album.queried(params[:q]).order_by([:title, :asc]).page(params[:page])
      # TODO: Add an index on title to enable sorting on huge number of categories
      @categories = Category.queried(params[:q]).order_by([:category_name, :asc]).page(params[:page]) 
    end
  end
end
