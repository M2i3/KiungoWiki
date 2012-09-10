class CategoriesController < ApplicationController

  # only registered users can edit this wiki
  before_filter :authenticate_user!, :except => [:show, :lookup, :search]
  authorize_resource

  def show
    @category = Category.find(params[:id])
    respond_to do |format|
      format.xml { render :xml=>@category.to_xml(:except=>[:versions]) }
      format.json { render :json=>@category }
      format.html
    end
  end

  def new
    unless params[:q]
      redirect_to search_categories_path, :alert=>t("messages.category_new_without_query")
    else
      @category = Category.new(CategorySearchQuery.new(params[:q]).to_hash)
      respond_to do |format|      
        format.html # new.html.erb
        format.xml  { render :xml => @category }
      end
    end
  end

  def create

    @category = Category.new(params[:category])
    respond_to do |format|
      puts @category.to_xml
      if @category.save
        format.html { redirect_to(@category , :notice => 'Category succesfully created.') }
        format.xml  { render :xml => @category, :status => :created, :location => @category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @category = Category.find(params[:id])
  end 

  def update
    @category = Category.find(params[:id])
		
    respond_to do |format|
      if @category.update_attributes(params[:category])
        format.html { redirect_to(@category, :notice => "Category succesfully updated.") }
        format.xml  { render :xml => @category, :status => :ok, :location => @category }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @category = Category.find(params[:id])
    
    @category.destroy
    respond_to do |format|
      format.html { redirect_to(categories_url) }
      format.xml  { head :ok }
    end
  end

  def lookup
    csq = CategorySearchQuery.new(params[:q])

    respond_to do |format|
      format.json { 
        render :json=>(Category.queried(csq.objectq).limit(20).collect{|cat| 

          CategoryWikiLink.new(reference_text: "oid:#{cat.id} #{csq.metaq}").combined_link
              
        } << {id: params[:q].to_s, name: params[:q].to_s + " (nouveau)"})           
      }
    end
  end

  protected
  def filter_params
    {
      :q => lambda {|categories, params| categories.queried(params[:q]) }
    }
  end

  def build_filter_from_params(params, categories)

    filter_params.each {|param_key, filter|
      puts "searching using #{param_key} with value #{params[param_key]}"
      categories = filter.call(categories,params) if params[param_key]
    }

    categories = categories.page(params[:page])

    categories
  end
end
