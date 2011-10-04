class WorksController < ApplicationController

  def index
    @works = Work.all#(sort: [:title, :asc]) TODO: Add an index on title to enable sorting on huge number of works
    @works = @works.queried(params[:q]) if params[:q]
    @works = @works.limit(100)

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
    respond_to do |format|
      format.json { render :json=>(Work.queried(params[:q]).limit(20).collect{|w| {id: "oid:#{w.id}", name: w.title} } << {id: params[:q].to_s, name: params[:q].to_s + " (nouveau)"}) }
    end
  end

end
