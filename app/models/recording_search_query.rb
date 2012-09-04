class RecordingSearchQuery < SearchQuery 
  def self.query_expressions
    superclass.query_expressions.merge({ 
      title: / title:([:print:]+) /,
      category: / category:([:print:]+) /,
      recording_date: :date,
      duration: :word,
      recording_location:  :text,
      rythm: :word,
      trackNb: / trackNb:([0-9]+) /,
      itemId: / itemId:([0-9a-zA-Z]+) /,
      itemSection: / itemSection:([A-Z1-9]) /,
      info: :text
    })
  end
  def self.catch_all
    "title"
  end 
end

