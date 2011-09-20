class WorkSearchQuery < SearchQuery 
  def self.query_expressions
    { title: / title:"(.+)" /,
      copyright: / copyright:([0-9]{4,4}) /,
      date_written: / date_written:([0-9]{4,4}(\-|\/)[0-9]{1,2}(\-|\/)[0-9]{1,2}) /,
      language:  / language:(\w+) /,
      publisher: / publisher:"(.+)" /,
      origworkid: / origworkid:([0-9]{1,10}) /
    }
  end
  def self.catch_all
    "title"
  end 
end

