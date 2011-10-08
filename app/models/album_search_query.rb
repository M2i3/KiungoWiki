class AlbumSearchQuery < SearchQuery 
  def self.query_expressions
    superclass.query_expressions.merge({ title: / title:[ "]*(.+?)[ "]* /,
      media_type: / media_type:[ "]*(.+?)[ "]* /,
      date_released: / date_released:[ "]*(.+?)[ "]* /,
      label: / label:[ "]*(.+?)[ "]* /,
      reference_code: / reference_code:[ "]*(.+?)[ "]* /
    })
  end
  def self.catch_all
    "title"
  end 
end

