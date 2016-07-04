require 'parslet' 
require 'json'

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
  def self.canonical_exclusion_fields
    []
  end
  
  def self.objectq_fields
    self.query_expressions.keys  - self.meta_fields - [:oid]
  end

  attr_reader :q

# to make this work you'll need to change this class into a module
#  self.query_expressions.keys.each {|key| attr_reader key }

  def initialize(query_value = "")
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
      else
        var_type = self.class.query_expressions[var_name.to_sym]
        self.instance_variable_set("@#{var_name}", cast_search_element(var_type, value.to_s))
      end
    else
      raise "undefined field #{var_name}"
    end
  end
  
  def q(separator=" ")
    unless @q
      filled_fields = self.filled_query_fields
      values = []
      @field_order.each {|var_name|
        filled_fields.delete(var_name.to_sym)
        values << self.full_field(var_name)
      }
      
      filled_fields.each {|var_name|
        values << self.full_field(var_name)
      }
      @q = values.join(separator)
    end
    
    @q
  end
  
  def url_encoded
    self.class.primary_display_text.collect{|k| self[k] }.join("-").parameterize + "_" + self.signature
    #self.q("_").gsub(' ', '-').gsub("'", '-').gsub(/[^a-zA-Z0-9\_\-\.\:]/, '') + "_" + self.signature
  end
  

  def q=(value)

    unless @q == value.to_s
      @field_order = []
      @q = value.to_s
    
      search_terms_symbols = SearchParser.new.parse(@q)
      search_terms_symbols = [] if search_terms_symbols == ""
      search_terms = []
      self.class.query_expressions.each {|var_name, var_expression|
        self.instance_variable_set("@#{var_name}", nil)
      }
    
      search_terms_symbols.each {|term|

        if term[:search_element]
        
          if term[:search_element].is_a?(Hash)
        
            var_name = term[:search_element][:field]
            var_type = self.class.query_expressions[var_name.to_sym]
        
            if var_name && query_fields.include?(var_name.to_sym)  
              self.instance_variable_set("@#{var_name}", cast_search_element(var_type, decode_search_element(term[:search_element])))
              @field_order << var_name
            end

          else
          
            search_terms << term[:search_element].str
          
          end

        end
      }
    
      if self.class.catch_all and not self.instance_variable_get("@#{self.class.catch_all}")
        self.instance_variable_set("@#{self.class.catch_all}", search_terms.join(" "))
        @field_order << self.class.catch_all
      end
    end
  end

  
  def format_value(type, value)
    case type
      when :word, :date, :numeric, :character, :duration
        "#{value}"
    else
      '"' + value.to_s.gsub('"','\"') + '"'
      #JSON::dump(value)
    end   
  end
  
  def decode_search_element(search_element)
    if search_element[:value] 
      search_element[:value].to_s
    elsif search_element[:string]
      search_element[:string].to_s.gsub('\"','"')
    end
  end
  
  def cast_search_element(type, value)
    begin
      case type
      when :text, :word
        value.to_s
      when :date
        IncDate.new(value)
      when :duration
        Duration.new(value)
      when :numeric
        value.to_i
      else
        value
      end
    rescue
      nil
    end
  end
  
  def metaq_fields 
    (self.filled_query_fields & self.class.meta_fields)
  end
  def objectq_fields
    (self.filled_query_fields - self.class.meta_fields)
  end

  def metaq
    self.metaq_fields.collect {|var_name| self.full_field(var_name) }.join(" ")
  end
  def objectq
    self.objectq_fields.collect {|var_name| self.full_field(var_name) }.join(" ")
  end
  def objectq_display_text
    primary_display_fields = (self.objectq_fields & self.class.primary_display_text)
    additional_display_fields = (self.objectq_fields - self.class.primary_display_text - self.class.hidden_display_text)
    
    display_text = primary_display_fields.collect {|var_name| self.instance_variable_get("@#{var_name}") }.join(" ")
    
    unless additional_display_fields.empty?
      display_text << " [ " unless primary_display_fields.empty?
      display_text << additional_display_fields.collect {|var_name| self.full_field(var_name) }.join(" ")
      display_text << " ]" unless primary_display_fields.empty?
    end
    
    display_text
  end
  
  def canonical_text
    (self.query_fields - self.class.meta_fields - self.class.canonical_exclusion_fields - [:oid]).sort.collect {|var_name| "#{var_name}: " + self.instance_variable_get("@#{var_name}").to_s }.join("\n")
  end
  def signature
    Digest::SHA1.hexdigest(self.canonical_text)
  end
  
  def full_field(var_name)
    var_name.to_s + ":" + format_value(self.class.query_expressions[var_name], self.instance_variable_get("@#{var_name}"))
  end
  
  class SearchParser < Parslet::Parser
    rule(:colon) { str(":") }
    rule(:space)  { match('\s').repeat(1) }
    rule(:space?) { space.maybe }
    rule(:spaces) { space.repeat(0) }
    rule(:number) { match('[0-9]').repeat(1) }

    rule(:word) { match('[^\s]').repeat(1) }

    rule(:empty_string) {
      str('"') >> str('"')      
    }

    rule(:string) {
      str('"') >> (
        str('\\') >> any |
        str('"').absent? >> any 
      ).repeat.as(:string) >> str('"') 
    }

    rule(:symbol) { match('[a-z_\-]').repeat(1) }
    rule(:field) { symbol.as(:field) }
    rule(:value) { ( empty_string | string | word.as(:value) ) }
    rule(:domain_search) { ( field >> colon >> value ) }

    rule(:search_element) { ( domain_search | word ).as(:search_element) >> space.maybe  } 
    rule(:search_query) { space.maybe >> search_element.repeat(0) }

    root(:search_query)

  end
end
