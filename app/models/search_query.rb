class SearchQuery
  def self.query_expressions
    {}
  end
  def self.catch_all
    nil
  end

  attr_reader :q

# to make this work you'll need to change this class into a module
#  self.query_expressions.keys.each {|key| attr_reader key }

  def initialize(query_value = nil)
    self.q = query_value    
  end

  def query_fields
    self.class.query_expressions.keys
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
    self.class.query_expressions.each {|var_name, expression|
      if match_result = expression.match(value)
        self.instance_variable_set("@#{var_name}", match_result[1])
        # remove the value found from the searh string
        value[match_result.offset(0)[0]..(match_result.offset(0)[1] - 1 )] = " "   
      else
        self.instance_variable_set("@#{var_name}", nil)
      end
    }
    if self.class.catch_all and not self.instance_variable_get("@#{self.class.catch_all}")
      self.instance_variable_set("@#{self.class.catch_all}", value.strip) 
    end
  end
end
