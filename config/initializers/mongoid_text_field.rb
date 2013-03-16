module Mongoid #:nodoc

  # This module defines behaviour for fields.
  module Fields

    def form_text_fields
      @form_text_fields ||= {}
    end

    module ClassMethods #:nodoc

      def field_with_text_field(name, options = {})
        field_without_text_field(name, options)

        self.class_eval(<<-EOL, __FILE__, __LINE__)

            def #{name}_text=(value)
              form_text_fields["#{name}"] = value
              begin
                self.#{name} = value
              rescue
              end                
            end

            def #{name}_text
              form_text_fields["#{name}"] || self.#{name}
            end
          EOL
      end
      alias_method_chain :field, :text_field

    end
  end
end

