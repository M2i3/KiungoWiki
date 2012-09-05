class AlbumSearchQuery < SearchQuery 
  def self.query_expressions
    superclass.query_expressions.merge({ title: :text,
      media_type: :text,
      date_released: :date,
      label: :text,
      reference_code: :text,
      trackNb: / trackNb:([0-9]+) /,
      itemId: / idemId:([0-9a-zA-Z]+) /,
      itemSection: / itemSection:([A-Z]) /,
      info: :text
    })
  end
  def self.catch_all
    "title"
  end 
end

