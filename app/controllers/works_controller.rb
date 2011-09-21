class WorksController < ApplicationController

  def index
    @works = Work.all

    respond_to do |format|
      format.xml { render :xml=>@works }
      format.json { render :json=>@works }
      format.html
    end
  end

  def show
    @work = Work.find(params[:id])

    respond_to do |format|
      format.json { render :json=>@work }
      format.html
    end
  end

  def new

    @work = Work.new
    respond_to do |format|      
      format.html # new.html.erb
      format.xml  { render :xml => @work }
    end
  end

  def create

    @work = Work.new(params[:work])

    respond_to do |format|
      puts @work.to_xml
      if @work.save
        format.html { redirect_to(@work , :notice => 'Work succesfully created.') }
        format.xml  { render :xml => @work, :status => :created, :location => @work }

      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @work.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit 
    @work = Work.find(params[:id])
  end 

  def update
    @work = Work.find(params[:id])

    respond_to do |format|
      if @work.update_attributes(params[:work])
        format.html { redirect_to(@work, :notice => "Work succesfully updated.") }
        format.xml  { render :xml => @work, :status => :ok, :location => @work }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @work.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @work = Work.find(params[:id])
    
    @work.destroy
    respond_to do |format|
      format.html { redirect_to(works_url) }
      format.xml  { head :ok }
    end
  end

  def lookup
# find an encoding that allows determining it's not really BSON ID
    respond_to do |format|
      #careful here not to allow injection of bad stuff in the regex
      format.json { render :json=>(Work.where(:title=>/#{params[:q]}/i).only(:title).limit(20).collect{|w| {id: w.id.to_s.to_query("b"), title: w.title} } << {id: Base64::encode64(params[:q]).to_query("u"), title: params[:q] + " (nouveau)"}) }
    end
  end

end
