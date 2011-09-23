class Duration < String
  include Mongoid::Fields::Serializable
  
  attr_reader :minutes, :seconds

  def deserialize(value)

    value = nil if value.blank?

    case value
    when ::Fixnum        
      return deserialize(value.to_s)
    when ::Hash
      @minutes, @seconds = value[:minutes], value[:seconds]
    when ::Duration
      @minutes, @seconds = value.minutes, value.seconds
    when ::String
      if value =~ /^(\d{1,4})(?:\:?(\d{2}))?$/
        @minutes = $1 ? $1.to_i : 0
        @seconds = $2 ? $2.to_i : 0
      end
    when nil #invaluable for existing databases!
     @minutes, @seconds = 0, 0, 0
    else
      raise ArgumentError, "Unexpected duration of type #{value.class} when instancing #{self.class.name}"
    end

    @minutes = 0 if @minutes.nil?
    @seconds = 0 if @seconds.nil?
    
    self.replace(to_s)
    self
  end

  def valid_seconds?(seconds)
    return true if seconds.zero?
    (0..59).include?(seconds)
  end

  def seconds=(value)
    value = (value.nil?) ? 0 : value
    raise ArgumentError, "invalid seconds" unless valid_seconds?(value)
    @seconds = value
  end

  def minutes=(value)
    value = (value.nil?) ? 0 : value
    raise ArgumentError, "invalid minutes" unless valid_minutes?(value)
    @minutes = value
  end


  VALID_DURATION_PARTS = [ :minutes, :seconds]

  def [](part_name)
    raise ArgumentError, "Invalid duration part #{part_name}" unless VALID_DURATION_PARTS.include?(part_name)
    self.send(part_name)
  end

  def []=(part_name, value)
    raise ArgumentError, "Invalid duration part #{part_name}" unless VALID_DURATION_PARTS.include?(part_name)
    self.send("#{part_name}=", value)
  end

  def incomplete?
    @seconds.nil? || @minutes.nil?
  end

  def complete?
    !incomplete?
  end

  def empty?
    @seconds.nil? && @minutes.nil?
  end

  def has?(*parts)
    parts.collect!(&:to_sym)
    parts.inject(true) { |total,part| total && !self.send(part).nil? }
  end

  def has_minutes?
    !@minutes.zero?
  end

  def has_seconds?
    !@seconds.zero?
  end

  def defined_parts
    VALID_DURATION_PARTS.reject { |part|  self[part].nil? }
  end


  def include?(duration)
    (self.minutes.nil? || (duration.minutes == self.minutes)) &&
    (self.seconds.nil? || (duration.seconds == self.seconds))
  end

  def to_incomplete_duration
    self
  end

  def to_i
    m,s = [minutes,seconds].collect(&:to_i) # converts +nil+ values to zero
    (s + m*60)
  end

  def to_s
    duration = @minutes.to_s + ":" + @seconds.to_s
    return duration
  end

  def to_hash
    result = {}
    VALID_DURATION_PARTS.each { |part| result[part] = self.send(part) }
    result
  end

end
