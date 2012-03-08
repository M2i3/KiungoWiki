require 'date'

class IncDate < String
  include Mongoid::Fields::Serializable
  include Comparable
  
  attr_reader :day, :month, :year
  alias mday day

  def initialize(value)

    value = nil if value.blank?

    case value
    when ::Fixnum        
      #num = value.abs
      #num, @day = num.divmod(100)
      #@year, @month = num.divmod(100)
      return initialize(value.to_s)
    when ::Hash
      @day, @month, @year = value[:day], value[:month], value[:year]
    when ::Date, ::Time, ::DateTime
      @day, @month, @year = value.mday, value.month, value.year
    when ::IncDate
      @day, @month, @year = value.day, value.month, value.year
    when ::String
      if value =~ /^(\d{4})(?:-?(\d{0,2})(?:-?(\d{0,2}))?)?$/
        @year = $1.to_i
        @month = $2 ? $2.to_i : 0
        @day = $3 ? $3.to_i : 0
      end
    when nil #invaluable for existing databases!
     @day, @month, @year = 0, 0, 0
    else
      raise ArgumentError, "Unexpected date of type #{value.class} when instancing #{self.class.name}"
    end

    @day = 0 if @day.nil?
    @month = 0 if @month.nil?
    @year = 0 if @year.nil?
    
    valid_date?
    
    self.replace(to_s)
    self
  end

  def deserialize(object)
    begin 
      ::IncDate.new(object)
    rescue
      nil
    end
  end

  
  #--
  # Core attributes handling
  #++

  #
  # Returns +true+ if the given year is a leap year, +false+ otherwise.
  #
  def self.leap_year?(year)
    raise ArgumentError, "year cannot be null or zero" if year.nil? or year.zero?
    (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0)
  end

  def self.max_month_days(month = nil, year = nil)
    year ||= 2000 # Assume a leap year if year is not known
    case month
    when nil,1,3,5,7,8,10,12 then 31
    when 4,6,9,11 then 30
    when 2 then leap_year?(year) ? 29 : 28
    else raise ArgumentError, "invalid month"
    end
  end

  def valid_day?(day, month = nil, year = nil)
    return true if day.zero?
    max = self.class.max_month_days(month || self.month, year || self.year)
    (1..max).include?(day)
  end

  def valid_month?(month)
    return true if month.zero?
    (1..12).include?(month) && valid_day?(self.day, month)
  end

  def valid_year?(year, month = nil, day = nil)
    return true if year.nil? || year.zero?
    day ||= self.day
    month ||= self.month
    !(!self.class.leap_year?(year) && (day == 29) && (month == 2))
  end
  
  def valid_date?
     unless @month.zero?
        unless @day.zero?
          ::Date.civil( @year, @month, @day)
        else
          ::Date.civil( @year, @month)
        end
      else
        ::Date.civil( @year)
      end
  end

  def day=(value)
    value = (value.nil?) ? 0 : value
    raise ArgumentError, "invalid day" unless valid_day?(value)
    @day = value
  end

  def month=(value)
    value = (value.nil?) ? 0 : value
    raise ArgumentError, "invalid month" unless valid_month?(value)
    @month = value
  end

  def year=(value)
    value = (value.nil?) ? 0 : value
    raise ArgumentError, "invalid year" unless valid_year?(value)
    @year = value
  end

  VALID_DATE_PARTS = [:year, :month, :day]

  def [](part_name)
    raise ArgumentError, "Invalid date part #{part_name}" unless VALID_DATE_PARTS.include?(part_name)
    self.send(part_name)
  end

  def []=(part_name, value)
    raise ArgumentError, "Invalid date part #{part_name}" unless VALID_DATE_PARTS.include?(part_name)
    self.send("#{part_name}=", value)
  end

  #--
  # Testing completeness
  #++

  def incomplete?
    @day.nil? || @month.nil? || @year.nil?
  end

  def complete?
    !incomplete?
  end

  def empty?
    @day.nil? && @month.nil? && @year.nil?
  end

  def blank?
    empty? || (@day == 0 && @month == 0 && @year == 0)
  end

  def has?(*parts)
    parts.collect!(&:to_sym)
    parts.inject(true) { |total,part| total && !self.send(part).nil? }
  end

  def has_day?
    !@day.zero?
  end

  def has_month?
    !@month.zero?
  end

  def has_year?
    !@year.zero?
  end

  def defined_parts
    VALID_DATE_PARTS.reject { |part|  self[part].nil? }
  end

  #++
  # Relation to complete dates
  #--

  #
  # Returns +true+ if the given date is included in the possible set of complete
  # dates that match this incomplete date.
  #
  # For instance 2003-xx-xx includes 2003-12-24 (or any date within the year
  # 2003) but it does not include 1999-12-14, for instance.
  #
  # The argument can be either a Date instance or an IncompleteDate instance.
  #
  def include?(date)
    (self.year.nil? || (date.year == self.year)) &&
    (self.month.nil? || (date.month == self.month)) &&
    (self.day.nil? || (date.mday == self.mday))
  end

  #
  # Returns the lowest possible date that matches this incomplete date.
  #
  # Only defined if this incomplete date has the year part defined. Otherwise it
  # returns +nil+.
  #
  # see #highest
  #
  def lowest
    return nil unless has_year?
    ::Date.civil(self.year, self.month || 1, self.day || 1)
  end
  alias min lowest
  alias first lowest

  #
  # Returns the highest possible date that matches this incomplete date.
  #
  # Only defined if this incomplete date has the year part defined. Otherwise it
  # returns +nil+.
  #
  # see #lowest
  #
  def highest
    return nil unless has_year?
    max_month = self.month || 12
    max_day = self.day || self.class.max_month_days(max_month, self.year)
    ::Date.civil(self.year, max_month, max_day)
  end
  alias max highest
  alias last highest

  #--
  # Conversions
  #++

  #
  # Converts this incomplete date to a standard date value. Any missing date
  # parts can be provided by the hash argument, or else are taken from today's
  # date, or a reference date that be given as an optional argument with key
  # +:ref+. In the case of the day missing and not explicitely provided, it
  # defaults to 1, and not to the reference date.
  #
  def to_date(opts = {})
    ref = opts.fetch(:ref, ::Date.today)
    ::Date.civil(
      (self.year || opts[:year] || ref.year).to_i,
      (self.month != 0 ? self.month : (opts[:month] || ref.month)).to_i,
      (self.day != 0 ? self.day : (opts[:day] || 1)).to_i)
  end

  def to_incomplete_date
    self
  end

  #
  # Converts this incomplete date to its equivalent integer representation
  # suitable for the database layer.
  #
  # The two less significant digits in the decimal representation of the number
  # are the day of the month. The next two less significant digits represent the
  # month (numbered from 01 to 12) and the rest of the digits represent the
  # year. In any case a value of zero means that that particular part of the
  # date is not known. Finally, the sign of the number represents wether the
  # date is considered to be uncertain (negative) or certain (positive).
  #
  # This representation relies on the fact there was no year 0 in the Gregorian
  # or Julian calendars (see http://en.wikipedia.org/wiki/Year_zero).
  #
  # The integer value zero represents a date that is completely unknown, so it
  # is somehow equivalent to +nil+ in terms of meaning, and it is questionable
  # that we allow instances of this class with such a configuration.
  #
  def to_i
    y,m,d = [year,month,day].collect(&:to_i) # converts +nil+ values to zero
    (d + m*100 + y*10000)
  end

#  def to_s
#    dt = to_date
#    ord = has_day? ? dt.day.ordinalize : nil
#    result = case defined_parts
#      when [:year, :month, :day] then dt.strftime("%B #{ord}, %Y")
#      when [:year, :month] then dt.strftime("%B %Y")
#      when [:month, :day] then dt.strftime("%B #{ord}")
#      when [:year, :day] then dt.strftime("#{ord} of the month, %Y")
#      when [:year] then dt.strftime("%Y")
#      when [:month] then dt.strftime("%B")
#      when [:day] then "#{ord} of the month"
#      else return "unknown"
#    end
#  end

  def to_s
    date = @year.to_s
    [@month, @day].each {|value|
      date += '-%02d' % value if value && value != 0
    }
      return date == "0" ? "" : date
  end

  #
  # Returns the range of dates that are included or match with this incomplete
  # date.
  #
  # Uses #lowest and #highest to determine the extremes of the range. Returns
  # +nil+ if the year is not defined.
  #
  def to_range
    has_year? ? (min..max) : nil
  end

  def to_hash
    result = {}
    VALID_DATE_PARTS.each { |part| result[part] = self.send(part) }
    result
  end

  def <=>(value)
    puts "testing dates with #{self.object_id} and #{value.object_id}"
    to_date <=> value.to_date
  end

end
