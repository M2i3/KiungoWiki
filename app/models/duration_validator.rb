class DurationValidator < ActiveModel::EachValidator

  # implement the method called during validation
  def validate_each(record, attribute, value)
    begin
      unless value.blank? && options[:allow_nil]
        elements = {}
        elements[:seconds], elements[:minutes], elements[:hours] = value.to_s.split(':').collect{|p| Integer(p) }.reverse

        [:seconds, :minutes, :hours].each {|k|
          raise "invalid duration #{k}" if elements[k] && elements[k] < 0   
        }

        raise "invalid duration" if elements[:seconds] && elements[:minutes].nil? && elements[:hours].nil? && elements[:seconds] == 0   
        
        
      end
    rescue
      record.errors[attribute] << 'must be a valid duration'
    end
  end

end
