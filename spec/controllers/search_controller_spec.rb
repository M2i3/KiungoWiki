require 'spec_helper'

describe SearchController do
  it "should redirect to root_path if no params[:q]" do
    SearchController.any_instance.should_receive(:redirect_to).with root_path
    get :index
  end
  it "should query recordings, artists, works, recordings, albums, and categories" do
    q = "q"
    page = 1.to_param
    Artist.should_receive(:order_by).with([:name, :asc]).and_return Artist
    Artist.should_receive(:queried).with(q).and_return Artist
    Artist.should_receive(:page).with(page)
    
    [Work, Recording, Release].each do |klass|
      klass.should_receive(:order_by).with([:title, :asc]).and_return klass
      klass.should_receive(:queried).with(q).and_return klass
      klass.should_receive(:page).with(page)
    end
    
    Category.should_receive(:order_by).with([:category_name, :asc]).and_return Category
    Category.should_receive(:queried).with(q).and_return Category
    Category.should_receive(:page).with(page)
    
    get :index, q: q, page: page
  end
end
