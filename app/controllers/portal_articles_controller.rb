class PortalArticlesController < ApplicationController
  # only registered users can edit this wiki
  before_filter :authenticate_user!, :except => [:show, :index]
  before_filter :find_entity, :except=>[:index, :new, :create]

  def index
    @category = params[:category]
    @portal_articles = PortalArticle.all
    @portal_articles = @portal_articles.where(category:@category) if @category
    @portal_articles = @portal_articles.where(:publish_date.lte => Time.now) unless current_user
    @portal_articles = @portal_articles.page(params[:page])
  end

  def show
  end

  def new
    @portal_article = PortalArticle.new(:category => (params[:category] || "general"))
  end

  def create

    @portal_article = PortalArticle.new(params[:portal_article])
  
    if @portal_article.save
      redirect_to(@portal_article , :notice => 'Article succesfully created.')
    else
      render :action => "new"
    end

  end

  def edit 
  end 

  def update

    if @portal_article.update_attributes(params[:portal_article])
      redirect_to(@portal_article, :notice => "Article succesfully updated.")
    else
      render :action => "edit"
    end
  end

  protected
  def find_entity
    @portal_article = PortalArticle.find(PortalArticle.id_from_param(params[:id]))
  end

end
