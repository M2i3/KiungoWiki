class CategoryWikiLink < WikiLink
  include Mongoid::Document

  set_reference_class Category
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


  class SearchQuery < ::SearchQuery 
    def self.query_expressions
      superclass.query_expressions.merge({
        category_name: :text
      })
    end
    def self.catch_all
      "category_name"
    end 
  end
end






