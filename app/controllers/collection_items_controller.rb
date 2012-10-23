class CollectionItemsController < ApplicationController

  # only for the registered users
  before_filter :authenticate_user!

  def index
    @items = current_user.collection_items.all
    render :text=>@items.collect{|i| i.id}.join(", ")
  end

  def show
    @item = current_user.collection_items.find(params[:id])
  end

  def new
    @item = current_user.collection_items.build
  end
  
  def create
    @item = current_user.collection_items.new(params[:collection_item])

    respond_to do |format|
      if @item.save
        format.html { redirect_to(@item , :notice => 'Collection Item Added Succesfully.') }
        format.xml  { render :xml => @item, :status => :created, :location => @item }

      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @item = current_user.collection_items.find(params[:id])
  end

  def update
    @item = current_user.collection_items.find(params[:id])

    respond_to do |format|
      if @item.update_attributes(params[:collection_item])
        format.html { redirect_to(@item, :notice => "Collection Item succesfully updated.") }
        format.xml  { render :xml => @item, :status => :ok, :location => @item }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

end

