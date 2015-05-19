class SearchQuery
  def self.query_expressions
    {oid: :word}
  end
  def self.catch_all
    nil
  end
  def self.meta_fields
    []
  end
  def self.primary_display_text
    []
  end
  def self.hidden_display_text
    []
  end
  
  def self.objectq_fields
    self.query_expressions.keys  - self.meta_fields - [:oid]
  end

  attr_reader :q

# to make this work you'll need to change this class into a module
#  self.query_expressions.keys.each {|key| attr_reader key }

  def initialize(query_value = nil)
    @q = nil
    @field_order = []
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

  def [](var_name)
    if query_fields.include?(var_name) 
      self.instance_variable_get("@#{var_name}")
    else
      raise "undefined field #{var_name}"
    end
  end
  
  def []=(var_name,value)
    if query_fields.include?(var_name) 
      @q = nil
      
      if value.nil?
        self.instance_variable_set("@#{var_name}", nil)
        self.instance_variable_set("@full_#{var_name}", nil)        
      else
        self.instance_variable_set("@#{var_name}", value.to_s)
        self.instance_variable_set("@full_#{var_name}", var_name.to_s + ":" + format_value(self.class.query_expressions[var_name  ], value))
      end
    else
      raise "undefined field #{var_name}"
    end
  end
  
  def q
    unless @q
      filled_fields = self.filled_query_fields
      values = []
      @field_order.each {|var_name|
        filled_fields.delete(var_name)
        values << self.instance_variable_get("@full_#{var_name}") 
      }
      
      filled_fields.each {|var_name|
        values << self.instance_variable_get("@full_#{var_name}") 
      }
      puts values.inspect
      @q = values.join(" ")
    end
    
    @q
  end

  def q=(value)
    @field_order = []
    @q = value.to_s
    value = " " + @q + " "
    self.class.query_expressions.each {|var_name, var_expression|

      self.instance_variable_set("@#{var_name}", nil)
      self.instance_variable_set("@full_#{var_name}", nil)

      build_expression(var_name, var_expression).each {|expression|
        if match_result = expression.match(value) and not self.instance_variable_get("@#{var_name}")
          
          self.instance_variable_set("@#{var_name}", match_result[1].strip)
          self.instance_variable_set("@full_#{var_name}", match_result[0].strip)
          
          # store the order of the value
          @field_order << var_name
          # remove the value found from the searh string
          value[match_result.offset(0)[0]..(match_result.offset(0)[1] - 1 )] = " "
        end        
      }
    }
    if self.class.catch_all and not self.instance_variable_get("@#{self.class.catch_all}")
      @field_order << self.class.catch_all
      self.instance_variable_set("@#{self.class.catch_all}", value.strip)
      self.instance_variable_set("@full_#{self.class.catch_all}", "#{self.class.catch_all}:\"#{value.strip}\"")  
    end
    
    @field_order.compact!
  end

  def build_expression(var_name, var_expression)
    case var_expression
      when :word
        [/ #{var_name}:([a-zA-Z0-9-]+?) /i]
      when :text
        [/ #{var_name}:"(.+?)"/i, / #{var_name}:(.+?) /i]
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
  
  def format_value(type, value)
    case type
      when :word, :date, :numeric, :character, :duration
        "#{value}"
    else
        "\"#{value}\""
    end   
  end
  
  def metaq_fields 
    (self.filled_query_fields & self.class.meta_fields)
  end
  def objectq_fields
    (self.filled_query_fields - self.class.meta_fields)
  end

  def metaq
    self.metaq_fields.collect {|var_name| self.instance_variable_get("@full_#{var_name}") }.join(" ")
  end
  def objectq
    self.objectq_fields.collect {|var_name| self.instance_variable_get("@full_#{var_name}") }.join(" ")
  end
  def objectq_display_text
    primary_display_fields = (self.objectq_fields & self.class.primary_display_text)
    additional_display_fields = (self.objectq_fields - self.class.primary_display_text - self.class.hidden_display_text)
    
    display_text = primary_display_fields.collect {|var_name| self.instance_variable_get("@#{var_name}") }.join(" ")
    
    unless additional_display_fields.empty?
      display_text << " [ " unless primary_display_fields.empty?
      display_text << additional_display_fields.collect {|var_name| self.instance_variable_get("@full_#{var_name}") }.join(" ")
      display_text << " ]" unless primary_display_fields.empty?
    end
    
        
    display_text
  end
  
  def canonical_text
    (self.query_fields - self.class.meta_fields - [:oid]).collect {|var_name| "#{var_name}: " + self.instance_variable_get("@#{var_name}").to_s }.join("\n")
  end
  def signature
    Digest::SHA1.hexdigest(self.canonical_text)
  end
end
