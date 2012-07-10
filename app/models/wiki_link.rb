module WikiLink
  extend ActiveSupport::Concern

  included do

    field :reference_text, :default=>""
    embedded_in :linkable, :polymorphic => true

  end

  def reference_text=(value)
    self[:reference_text] = value
    sq = search_klass.new(value)
    if sq[:oid]
      self.referenced = referenced_klass.find(sq[:oid]) 
    else
      self.referenced = nil
    end
  end

  def role
    searchref[:role]
  end

  def display_text
    throw NotImplementedError
  end

  def combined_link
    {id: self.reference_text.to_s, name: self.display_text}
  end 

  def referenced=(obj)
    self.send("#{reference_field}=".to_sym, obj)
  end
  def referenced
    self.send(reference_field.to_sym)
  end

  def searchref
    search_klass.new(self.reference_text)
  end

  def metaq  
    self.searchref.metaq
  end

  def objectq  
    self.searchref.objectq
  end

  module ClassMethods

    def set_reference_class(klass, search_klass)

      class_eval <<-EOM
        def search_klass
          #{search_klass}
        end

        def referenced_klass
          #{klass}
        end

        def reference_field
          "#{klass.to_s.downcase}"
        end
      EOM

      referenced_in klass.to_s.downcase.to_sym

    end
  end

end

