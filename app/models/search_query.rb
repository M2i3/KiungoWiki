class SearchQuery
  def self.query_expressions
    {oid: / oid:([0-9a-f]{24}) /}
  end
  def self.catch_all
    nil
  end
  def self.meta_fields
    []
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

  def filled_query_fields
    self.class.query_expressions.keys.find_all {|field| not self[field].blank? }
  end

  def to_hash
    attributes = {}
    filled_query_fields.each{|k|
      attributes[k] = self[k]
    }
    attributes
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
    self.class.query_expressions.each {|var_name, var_expression|

      self.instance_variable_set("@#{var_name}", nil)
      self.instance_variable_set("@full_#{var_name}", nil)

      build_expression(var_name, var_expression).each {|expression|
        if match_result = expression.match(value)
          self.instance_variable_set("@#{var_name}", match_result[1].strip)
          self.instance_variable_set("@full_#{var_name}", match_result[0].strip)
          # remove the value found from the searh string
          value[match_result.offset(0)[0]..(match_result.offset(0)[1] - 1 )] = " "   
        end        
      }
    }
    if self.class.catch_all and not self.instance_variable_get("@#{self.class.catch_all}")
      self.instance_variable_set("@#{self.class.catch_all}", value.strip)
      self.instance_variable_set("@full_#{self.class.catch_all}", "#{self.class.catch_all}:\"#{value.strip}\"")  
    end
  end

  def build_expression(var_name, var_expression)
    case var_expression
      when :word
        [/ #{var_name}:([a-zA-Z0-9-]+?) /i]
      when :text
        [/ #{var_name}:"(.+?)" /i, / #{var_name}:(.+?) /i]
      when :date
        [/ #{var_name}:(.+?) /i]
      when :numeric
        [/ #{var_name}:([0-9]+?) /i]
      when :character
        [/ #{var_name}:([0-9a-zA-Z]?) /i]
      when :duration
        [/ #{var_name}:([0-9]+[:][0-5][0-9]?) /i]
      else
        (var_expression.respond_to?(:each) ? var_expression : [var_expression])
    end
  end

  def metaq
    (self.filled_query_fields & self.class.meta_fields).collect {|var_name| self.instance_variable_get("@full_#{var_name}") }.join(" ")
  end
  def objectq
    (self.filled_query_fields - self.class.meta_fields).collect {|var_name| self.instance_variable_get("@full_#{var_name}") }.join(" ")
  end
end
