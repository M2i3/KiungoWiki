class AlbumSearchQuery < SearchQuery 
  def self.query_expressions
    superclass.query_expressions.merge({ title: / title:"(.+?)" /,
      media_type: / media_type:"(.+?)" /,
      date_released: / date_released:([0-9]{4,4}(\-|\/)[0-9]{1,2}(\-|\/)[0-9]{1,2}) /,
      label: / label:"(.+?)" /,
      reference_code: / reference_code:"(.+?)" /
    })
  end
  def self.catch_all
    "title"
  end 
end

