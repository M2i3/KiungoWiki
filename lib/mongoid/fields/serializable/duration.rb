# encoding: utf-8
module Mongoid #:nodoc:
  module Fields #:nodoc:
    module Serializable #:nodoc:
      class Duration
        include Mongoid::Fields::Serializable
        
        attr_reader :hours, :minutes, :seconds

        def serialize(object)
          if object.blank? 
            nil
          else
            begin 
              deserialize(object).to_i
            rescue
              nil
            end
          end 
        end

        def deserialize(object)
          ::Duration.new(object)
        end

      end    
    end
  end
end
