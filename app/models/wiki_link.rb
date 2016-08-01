class  WikiLink
  include Mongoid::Document
  include ::WikiLinkFields

#  field :reference_text, default: ""
  field :signature, default: nil
  embedded_in :linkable, polymorphic: true
    
  before_save :save_signature
  
  def reference_text=(value)
    self.searchref = self.class.search_query(value)
  end
  
  def reference_text
    self.searchref.q
  end
  
  def searchref
    @search_ref
      @search_ref = self.class.search_query
      self.class.wiki_link_fields.each {|k,v|
        @search_ref[k] = self[k]
      }
      self.class.wiki_link_additional_fields.each {|k,v|
        @search_ref[k] = self[k]
      }
    
    @search_ref
  end
  def searchref=(value)
    @search_ref = value
    self.class.wiki_link_fields.each {|k,v|
      self[k] = @search_ref[k]
    }
    self.class.wiki_link_additional_fields.each {|k,v|
      self[k] = @search_ref[k]
    }
  end
  
  def signature
    self[:signature] ||= self.searchref.signature
  end
    
  def reference_signature
    self.signature || self.searchref.signature
  end

  def combined_link
    {id: self.reference_text.to_s, name: self.display_text}
  end 

  def referenced=(obj)
    self.send("#{self.class.reference_field}=".to_sym, obj)
  end
  def referenced
    self.send(self.class.reference_field.to_sym)
  end

  def metaq  
    self.searchref.metaq
  end
  def metaq=(text)
    self.reference_text = [self.objectq, text].join(" ")
  end

  def objectq  
    self.searchref.objectq
  end
  
  def objectq_display_text
    self.searchref.objectq_display_text
  end

  def object_text
    throw NotImplementedError
  end

  def display_text
    object_text + (self.metaq.blank? ? "" : " (#{self.metaq})")
  end

  def save_signature
    self.signature = self.searchref.signature
  end
  
  class << self    

    def define_subclass_signed_as(models)
      models = [models].flatten.collect{|m| m.to_s.classify }
      define_singleton_method :all_signed_as do |signature|
        models.collect{|model|
          model.constantize.all_signed_as(signature)
        }.flatten.compact
      end
      define_singleton_method :signed_as do |signature|
        models.collect{|model|
          model.constantize.signed_as(signature)
        }.compact.first
      end
    end
    def define_signed_as(model, method)
      define_singleton_method :all_signed_as do |signature|
        signature = signature.split("_").last 
        model_instances =  model.where(:"#{method.to_s}.signature" => signature)
        if model_instances.empty?
          []
        else
          model_instances.collect{|model_instance|
            if model_instance.send(method.to_sym).is_a?(WikiLink)
              model_instance.send(method.to_sym)
            else
              model_instance.send(method.to_sym).where(:signature => signature)
            end
          }.flatten
        end
      end
      define_singleton_method :signed_as do |signature|
        signature = signature.split("_").last 
        model_instance =  model.where(:"#{method.to_s}.signature" => signature).first
        if model_instance
          if model_instance.send(method.to_sym).is_a?(WikiLink)
            model_instance.send(method.to_sym)
          else
            model_instance.send(method.to_sym).where(:signature => signature).first
          end
        end
      end
    end

    def set_reference_class(klass)

      class_eval <<-EOM
        class << self
          def referenced_klass
            #{klass}
          end

          def reference_field
            "#{klass.to_s.downcase}"
          end
        end
        
        def #{klass.to_s.downcase}_with_ghost
          unless self.#{klass.to_s.downcase}_without_ghost
            @referenced_object ||= (self.reference_signature && #{klass.to_s}.where(signature: self.reference_signature).extras(:hint => {:signature => 1}).limit(1).first ) || #{klass.to_s}.new
          else
            @referenced_object ||= self.#{klass.to_s.downcase}_without_ghost
          end
        end
      EOM


      belongs_to klass.to_s.downcase.to_sym, inverse_of: nil

      alias_method_chain klass.to_s.downcase.to_sym, :ghost      
    end

    def search_klass
      unless self == WikiLink
        self::SearchQuery
      else
        ::SearchQuery
      end
    end
    
    def search_query(q = "")
      if self.respond_to?(:search_klass)
        self.search_klass.new(q)
      else
        self::SearchQuery.new(q)
      end
    end

  end # class << self

end
