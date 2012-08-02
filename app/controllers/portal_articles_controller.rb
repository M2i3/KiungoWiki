class PortalArticlesController < ApplicationController
  # only registered users can edit this wiki
  before_filter :authenticate_user!, :except => [:show, :index]

  def index
    @category = params[:category]
    @portal_articles = PortalArticle.all
    @portal_articles = @portal_articles.where(category:@category) if @category
    @portal_articles = @portal_articles.page(params[:page])
  end

  def show
    @portal_article = PortalArticle.find(params[:id])
  end

  def new
    @portal_article = PortalArticle.new(:category => (params[:category] || "work"))
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
    @portal_article = PortalArticle.find(params[:id])
  end 

  def update
    @portal_article = PortalArticle.find(params[:id])

    if @portal_article.update_attributes(params[:portal_article])
      redirect_to(@portal_article, :notice => "Article succesfully updated.")
    else
      render :action => "edit"
    end
  end

end
