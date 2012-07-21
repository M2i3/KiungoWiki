module WikiLink
  extend ActiveSupport::Concern

  included do

    field :reference_text, :default=>""
    embedded_in :linkable, :polymorphic => true

  end

  def reference_text=(value)
    self[:reference_text] = value
    sq = self.class.search_klass.new(value)
    if sq[:oid]
      self.referenced = self.class.referenced_klass.find(sq[:oid]) 
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
    object_text + (self.metaq.empty? ? "" : " (#{self.metaq})")
  end

  module ClassMethods

    def set_reference_class(klass, search_klass)

      class_eval <<-EOM
        class << self
          def search_klass
            #{search_klass}
          end

          def referenced_klass
            #{klass}
          end

          def reference_field
            "#{klass.to_s.downcase}"
          end
        end
      EOM


      belongs_to klass.to_s.downcase.to_sym, inverse_of: nil

      
    end
  end

end


