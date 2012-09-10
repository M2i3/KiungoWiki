class AlbumSearchQuery < SearchQuery 
  def self.query_expressions
    superclass.query_expressions.merge({ title: :text,
      media_type: :text,
      date_released: :date,
      label: :text,
      reference_code: :text,
      trackNb: :numeric,
      itemId: :character,
      itemSection: :character,
      info: :text
    })
  end
  def self.catch_all
    "title"
  end 
end

