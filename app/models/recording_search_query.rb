class RecordingSearchQuery < SearchQuery 
  def self.query_expressions
    superclass.query_expressions.merge({ title: / title:"(.+?)" /,
      recording_date: / recording_date:([0-9]{4,4}(\-|\/)[0-9]{1,2}(\-|\/)[0-9]{1,2}) /, 
      recording_location:  / recording_location:"(.+?)" /,
      rythm: / rythm:([0-9]{1,3}) /        
    })
  end
  def self.catch_all
    "title"
  end 
end

