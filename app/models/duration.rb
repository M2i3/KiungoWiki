class Duration
  include Mongoid::Fields::Serializable
  
  attr_reader :hours, :minutes, :seconds

  def serialize(object)
    if object.blank? 
      nil
    else
      deserialize(object).to_i
    end 
  end

  def deserialize(object)

    object = nil if object.blank?

    case object
    when ::Integer
      @hours, @minutes, @seconds = (object / 3600), ((object % 3600) / 60), (object % 60)

    when ::Hash
      @hours, @minutes, @seconds = object[:hours], object[:minutes], object[:seconds]

    when ::Duration
      @hours, @minutes, @seconds = object.hours, object.minutes, object.seconds

    when ::String
      @seconds, @minutes, @hours = object.split(':').map(&:to_i).reverse

    when nil #invaluable for existing databases!
     @hours, @minutes, @seconds = 0, 0, 0

    else
      raise ArgumentError, "Unexpected duration of type #{object.class} when instancing #{self.class.name}"
    end

    @hours = 0 if @hours.nil?
    @minutes = 0 if @minutes.nil?
    @seconds = 0 if @seconds.nil?

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
    duration.join(":")
  end


  

  def valid_seconds?(seconds = self.seconds)
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


  def to_hash
    result = {}
    VALID_DURATION_PARTS.each { |part| result[part] = self.send(part) }
    result
  end

end
