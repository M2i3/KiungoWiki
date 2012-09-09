class GroupText
  def initialize(elements, options = {})
    @elements = elements  

    @element_separator = options[:sep] || " "
    @before_text = options[:before_text] || ""
    @after_text = options[:after_text] || ""  
  end

  def blank?
    @elements.all?{|a| a.blank?}
  end

  def non_blank
    @elements.find_all{|a| !a.blank?}
  end

  def to_s
    if blank?
      ""
    else
      @before_text + non_blank.join(@element_separator) + @after_text
    end 
  end
end
