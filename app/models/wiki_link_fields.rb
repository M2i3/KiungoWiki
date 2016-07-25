module WikiLinkFields
  class << self
    def included(base)
      base.extend ClassMethods
    end
  end

  module ClassMethods
    def wiki_link_field(name, options = {})
      @wiki_link_fields ||= {}
      @wiki_link_fields[name] = options
      field name, options
    end
    
    def wiki_link_additional_field(name, options = {})
      @wiki_link_additional_fields ||= {}
      @wiki_link_additional_fields[name] = options
      field name, options
    end

    def wiki_link_fields
      if self.superclass.respond_to?(:wiki_link_fields)
        self.superclass.wiki_link_fields.merge(@wiki_link_fields || {})
      else
        @wiki_link_fields || {}
      end
    end
    
    def wiki_link_additional_fields
      if self.superclass.respond_to?(:wiki_link_additional_fields)
        self.superclass.wiki_link_additional_fields.merge(@wiki_link_fields || {})
      else
        @wiki_link_additional_fields || {}
      end
    end
  end
end
