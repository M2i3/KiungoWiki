class WorkSearchQuery < SearchQuery 
  def self.query_expressions
    superclass.query_expressions.merge({ title: / title:"(.+)" /,
      copyright: / copyright:"(.+)" /,
      date_written: / date_written:([0-9]{4,4}(\-|\/)[0-9]{1,2}(\-|\/)[0-9]{1,2}) /,
      language_code:  / language_code:([a-zA-Z]{2,3}) /,
      publisher: / publisher:"(.+)" /,
      origworkid: / origworkid:([0-9]{1,10}) /
    })
  end
  def self.catch_all
    "title"
  end 
end

