class ProgressBar
  def initialize(every = 51)
    @i = 0
    @every = every
  end
  def inc
    @i += 1
    if @i % @every == 0 
      print "."
    end
  end
  def done
    puts ""
  end
end