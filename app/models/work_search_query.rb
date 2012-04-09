class WorkSearchQuery < SearchQuery 
  def self.query_expressions
    superclass.query_expressions.merge({ title: / title:(.+?) /,
      copyright: / copyright:(.+?) /,
      lyrics: / lyrics:(.+?) /,
      date_written: / date_written:(.+?) /,
      language_code:  / language_code:(.+?) /,
      publisher: / publisher:(.+?) /,
      role: / role:([[:alpha:]' \/]+) /,
      info: / info:(.+?) /
    })
  end
  def self.catch_all
    "title"
  end 
end

