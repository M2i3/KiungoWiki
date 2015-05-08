class PossessionsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource except: :index
  before_filter :set_search_domain
  
  # GET /possessions
  # GET /possessions.json
  def index
    @labelled = params[:label]
    @possessions = current_user.possessions
    @possessions = @possessions.where(labels:@labelled) if @labelled
    @possessions = @possessions.page(params[:page]).order_by(display_title:1).all

    @labels = current_user.labels.order_by([:count, :desc])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @possessions }
    end
  end

  # GET /possessions/1
  # GET /possessions/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @possession }
    end
  end

  # GET /possessions/new
  # GET /possessions/new.json
  def new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @possession }
    end
  end

  # GET /possessions/1/edit
  def edit
  end

  # POST /possessions
  # POST /possessions.json
  def create
    respond_to do |format|
      if @possession.save
        format.html { redirect_to @possession, notice: 'Possession was successfully created.' }
        format.json { render json: @possession, status: :created, location: @possession }
      else
        format.html { render action: "new" }
        format.json { render json: @possession.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /possessions/1
  # PUT /possessions/1.json
  def update
    
    respond_to do |format|
      if @possession.update_attributes(params[:possession])
        format.html { redirect_to @possession, notice: 'Possession was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @possession.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /possessions/1
  # DELETE /possessions/1.json
  def destroy
    @possession.destroy
    
    respond_to do |format|
      format.html { redirect_to possessions_url }
      format.json { head :no_content }
    end
  end

  protected
  def set_search_domain
    @search_domain = "my-music"
  end
    
end
