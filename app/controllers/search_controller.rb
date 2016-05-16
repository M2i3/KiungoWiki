class SearchController < ApplicationController
  
  def index
    unless params[:q]
      redirect_to root_path
    else
      @search_domain = params[:search_domain]
      if @search_domain == "all"
        @search_counts = {}

        # TODO: Add an index on name to enable sorting on huge number of artists
        @artists = Kaminari.paginate_array([]).page(params[:page]) 
        if ["all", "artists"].include?(@search_domain)
          query = Artist.queried(params[:q])
          @search_counts[:artists] = query.count
          @artists = query.order_by([:name, :asc]).page(params[:page]) 
        end
      
        # TODO: Add an index on title to enable sorting on huge number of works
        @works = Kaminari.paginate_array([]).page(params[:page]) 
        if ["all", "works"].include?(@search_domain)
          query = Work.queried(params[:q])
          @search_counts[:works] = query.count
          @works = query.order_by([:title, :asc]).page(params[:page])
        end
      
        # TODO: Add an index on title to enable sorting on huge number of recordings
        @recordings = Kaminari.paginate_array([]).page(params[:page]) 
        if ["all", "recordings"].include?(@search_domain)
          query = Recording.queried(params[:q])
          @search_counts[:recordings] = query.count
          @recordings = query.order_by([:title, :asc]).page(params[:page])
        end
      
        # TODO: Add an index on title to enable sorting on huge number of releases
        @releases = Kaminari.paginate_array([]).page(params[:page]) 
        if ["all", "releases"].include?(@search_domain)
          query = Release.queried(params[:q])
          @search_counts[:releases] = query.count
          @releases = query.order_by([:title, :asc]).page(params[:page])
        end      
      
        # TODO: Add an index on title to enable sorting on huge number of categories
        @categories = Kaminari.paginate_array([]).page(params[:page])   
        if ["all", "categories"].include?(@search_domain)
          query = Category.queried(params[:q])
          @search_counts[:categories] = query.count
          @categories = query.order_by([:category_name, :asc]).page(params[:page]) 
        end       
      else
        case @search_domain
        when "artists"
          redirect_to artists_path(q: params[:q])
        when "works"
          redirect_to works_path(q: params[:q])
        when "recordings"
          redirect_to recordings_path(q: params[:q])
        when "releases"
          redirect_to releases_path(q: params[:q])
        when "my-music"
          redirect_to possessions_path(q: params[:q])
        else
          redirect_to root_path
        end
      end
    end
  end
end
