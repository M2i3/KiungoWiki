class CategoryWikiLink < WikiLink
  include Mongoid::Document

  set_reference_class Category
  cache_attributes :category_name

  def origcategoryid
    (category && self.category.origcategoryid) || self.objectq
  end
  
  def object_text
    text = self.category_name.to_s
  end
  
  class SearchQuery < ::SearchQuery
    QUERY_ATTRS = { 
        category_name: :text
      }
    def self.query_expressions
      super.merge QUERY_ATTRS
    end
    def self.catch_all
      :category_name
    end 
    def self.primary_display_text
      [:category_name]
    end    
  end
  
  
end






