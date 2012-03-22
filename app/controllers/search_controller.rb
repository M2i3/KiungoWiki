class SearchController < ApplicationController
  def index
    unless params[:q]
      redirect_to root_path
    else
      @artists = Artist.all(sort: [:name, :asc]) #TODO: Add an index on title to enable sorting on huge number of artists
      @artists = @artists.queried(params[:q]) if params[:q]
      @artists = @artists.page(params[:page])

      @works = Work.all(sort: [:title, :asc]) #TODO: Add an index on title to enable sorting on huge number of works
      @works = @works.queried(params[:q]) if params[:q]
      @works = @works.page(params[:page])

      @recordings = Recording.all(sort: [:title, :asc]) #TODO: Add an index on title to enable sorting on huge number of recordings
      @recordings = @recordings.queried(params[:q]) if params[:q]
      @recordings = @recordings.page(params[:page])

      @albums = Album.all(sort: [:title, :asc]) # TODO: Add an index on title to enable sorting on huge number of albums
      @albums = @albums.queried(params[:q]) if params[:q]
      @albums = @albums.page(params[:page])
    end
  end
end
