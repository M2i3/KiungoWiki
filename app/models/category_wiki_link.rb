class CategoryWikiLink < WikiLink
  include Mongoid::Document

  set_reference_class Category, CategorySearchQuery
  cache_attributes :category_name

  def category_name
    (category && self.category.category_name) || self.objectq
  end

  def origcategoryid
    (category && self.category.origcategoryid) || self.objectq
  end
  
  def object_text
    text = self.category_name.to_s
  end
end






