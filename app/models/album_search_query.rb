class AlbumSearchQuery < SearchQuery 
  def self.query_expressions
    superclass.query_expressions.merge({ title: / title:(.+?) /,
      media_type: / media_type:(.+?) /,
      date_released: / date_released:(.+?) /,
      label: / label:(.+?) /,
      reference_code: / reference_code:(.+?) /,
      trackNb: / trackNb:([0-9]+) /,
      itemId: / idemId:([0-9a-zA-Z]+) /,
      itemSection: / itemSection:([A-Z]) /,
      info: / info:(.+?) /
    })
  end
  def self.catch_all
    "title"
  end 
end

