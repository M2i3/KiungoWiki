class RecordingSearchQuery < SearchQuery 
  def self.query_expressions
    superclass.query_expressions.merge({ 
      title: :text,
      category_name: :text,
      recording_date: :date,
      duration: :duration,
      recording_location:  :text,
      rythm: :word,
      trackNb: :numeric,
      itemId: :word,
      itemSection: :character,
      info: :text
    })
  end
  def self.catch_all
    "title"
  end 
  def self.meta_fields
    super + [:trackNb, :itemId, :itemSection]
  end

end

