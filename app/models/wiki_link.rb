class  WikiLink
  include Mongoid::Document

  field :reference_text, :default=>""
  embedded_in :linkable, :polymorphic => true

  def reference_text=(value)
    self[:reference_text] = value
    sq = self.class.search_klass.new(value)
    if sq[:oid]
      if self.referenced.nil? || self.referenced.id.to_s != sq[:oid]
        begin 
          self.referenced = self.class.referenced_klass.find(sq[:oid]) 
        rescue Mongoid::Errors::DocumentNotFound
          self.referenced = nil
        end
      end
    else
      self.referenced = nil
    end
  end

  def role
    searchref[:role]
  end

  def combined_link
    {id: self.reference_text.to_s, name: self.display_text}
  end 

  def referenced=(obj)
    self.send("#{self.class.reference_field}=".to_sym, obj)
    update_cached_attributes
  end
  def referenced
    self.send(self.class.reference_field.to_sym)
  end

  def searchref
    self.class.search_klass.new(self.reference_text)
  end

  def metaq  
    self.searchref.metaq
  end

  def objectq  
    self.searchref.objectq
  end

  def object_text
    throw NotImplementedError
  end

  def display_text
    object_text + (self.metaq.blank? ? "" : " (#{self.metaq})")
  end

  def update_cached_attributes
    cached_attributes.each{|a|
      if referenced
        self.send("c_#{a}=".to_sym, referenced.send(a.to_sym))
      else
        self.send("c_#{a}=".to_sym, nil)
      end
    }
  end

  def cached_attributes
    []
  end

  class << self

    def set_reference_class(klass, search_klass = nil)

      class_eval <<-EOM
        class << self
          def referenced_klass
            #{klass}
          end

          def reference_field
            "#{klass.to_s.downcase}"
          end
        end
      EOM

      set_search_class(search_klass) if search_klass

      belongs_to klass.to_s.downcase.to_sym, inverse_of: nil
      
    end

    def set_search_class(search_klass)

      class_eval <<-EOM
        class << self
          def search_klass
            #{search_klass}
          end
        end
      EOM

    end

    def cache_attributes(*attributes)

      attributes_list = attributes.collect{|a| ":#{a}"}.join(", ")

      class_eval <<-EOM
        def cached_attributes          
          super + [#{attributes_list}]
        end
      EOM

      attributes.each{|a|

        options = {}
        [:type].each{|option|
          options[option] = referenced_klass.fields[a.to_s].options[option] if referenced_klass.fields[a.to_s].options[option]
        }

        field "c_#{a}".to_sym, options

        class_eval <<-EOM

          def #{a}
            c_#{a} || (referenced && referenced.#{a})
          end

        EOM
        
      }

#
# Don't enable it yet, the propagation mechanism is not in place
#
#      before_save :update_cached_attributes

    end

  end # class << self

end


