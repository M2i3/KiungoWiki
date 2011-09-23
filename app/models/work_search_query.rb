class WorkSearchQuery < SearchQuery 
  def self.query_expressions
    superclass.query_expressions.merge({ title: / title:"(.+)" /,
      copyright: / copyright:"(.+)" /,
      date_written: / date_written:([0-9]{4,4}(\-|\/)[0-9]{1,2}(\-|\/)[0-9]{1,2}) /,
      language_id:  / language_id:([0-9]{1,3}) /,
      publisher: / publisher:"(.+)" /,
      origworkid: / origworkid:([0-9]{1,10}) /
    })
  end
  def self.catch_all
    "title"
  end 
end

