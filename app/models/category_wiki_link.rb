class CategoryWikiLink < WikiLink
  include Mongoid::Document

  set_reference_class Category, CategorySearchQuery

  def category_name
    (category && self.category.category_name) || self.objectq
  end

  def origcategoryid
    (category && self.category.origcategoryid) || self.objectq
  end
  
  def object_text
    self.category_name
  end
end






