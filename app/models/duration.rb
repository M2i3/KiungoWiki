class Duration

  attr_reader :hours, :minutes, :seconds

  def initialize(object)

    object = nil if object.blank?

    case object
      when ::Integer
        @hours, @minutes, @seconds = (object / 3600), ((object % 3600) / 60), (object % 60)

      when ::Hash
        @hours, @minutes, @seconds = object[:hours], object[:minutes], object[:seconds]

      when ::Duration
        @hours, @minutes, @seconds = object.hours, object.minutes, object.seconds

      when ::String
        begin 
          @seconds, @minutes, @hours = object.split(':').collect{|p| p.to_i }.reverse
        rescue
          raise ArgumentError, "Unexpected duration string #{object} when instancing #{self.class.name}"      
        end

      when nil #invaluable for existing databases!
       @hours, @minutes, @seconds = 0, 0, 0

      else
        raise ArgumentError, "Unexpected duration of type #{object.class} when instancing #{self.class.name}"
    end

    @hours = 0 if @hours.nil?
    @minutes = 0 if @minutes.nil?
    @seconds = 0 if @seconds.nil?

    @minutes += (@seconds / 60)
    @seconds = @seconds.modulo(60)

    @hours += (@minutes / 60)
    @minutes = @minutes.modulo(60)

    self

  end


  def to_i
    (seconds + minutes*60 + hours*3600)
  end

  def to_s
    duration = []
    duration << (hours.to_s) unless hours.zero?
    duration << (duration.empty? ? minutes.to_s : "00#{minutes}"[-2..-1]) unless (minutes.zero? && duration.empty?)
    duration << (duration.empty? ? seconds.to_s : "00#{seconds}"[-2..-1])
    d = duration.join(":")
    return d == "0" ? "" : d
  end

  def blank?
    self.to_s.blank? or self.to_i.blank?
  end


  class << self
    def mongoize(object)
      if object.blank? 
        nil
      else
        begin
          if object.is_a?(::Duration)
            object.to_i
          else
            Duration.new(object).to_i

          end
        rescue
          nil
        end
      end 
    end
    def demongoize(object)
      begin 
        ::Duration.new(object)
      rescue
        nil
      end
    end
  end
end
