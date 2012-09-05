class CategorySearchQuery < SearchQuery 
  def self.query_expressions
    superclass.query_expressions.merge({
      category_name: :text
    })
  end
  def self.catch_all
    "category_name"
  end 
end
