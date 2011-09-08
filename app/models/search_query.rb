class SearchQuery
  def self.query_expressions
    { title: / title:"(.+)" /, 
      date_written: / date_written:([0-9]{4,4}(\-|\/)[0-9]{1,2}(\-|\/)[0-9]{1,2}) /,
      language:  / language:(\w+) /,
      publisher: / publisher:"(.+)" /        
    }
  end

  QUERY_EXPRESSIONS = self.query_expressions

  attr_reader :q
  self.query_expressions.keys.each {|key| attr_reader key }

  def initialize(query_value = nil)
    self.q = query_value
    
  end

  def query_fields
    QUERY_EXPRESSIONS.keys
  end

  def [](key)
    if query_fields.include?(key) 
      self.instance_variable_get("@#{key}")
    else
      raise "undefined field #{key}"
    end
  end

  def q=(value)
    @q = value.to_s
    value = " " + @q + " "
    QUERY_EXPRESSIONS.each {|var_name, expression|
      if match_result = expression.match(value)
        puts "offsets are #{match_result.offset(0)[0]} .. #{match_result.offset(0)[1]}"
        puts "found #{value[match_result.offset(0)[0]..match_result.offset(0)[1]]}"
        self.instance_variable_set("@#{var_name}", match_result[1])
        # remove the value found from the searh string
        value[match_result.offset(0)[0]..(match_result.offset(0)[1] - 1 )] = " "
      else
        self.instance_variable_set("@#{var_name}", nil)
      end
    }
    @title = value.strip unless @title
  end
end
