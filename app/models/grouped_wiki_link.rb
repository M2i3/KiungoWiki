class GroupedWikiLink

  def initialize(klass, wiki_links)
    wiki_links.group_by{|wl| wl.objectq }.each{|objectq, links|
      groups << GroupWikiLink.new(objectq, klass, links)
      
    }
  end

  def groups
    @groups ||= []
  end

  class GroupWikiLink

    attr_reader :objectq
    
    def initialize(objectq, klass, wiki_links)
      @objectq = objectq
      @klass = klass
      wiki_links.each{|wl|
        links << wl 
      }
    end

    def links
      @links ||= []
    end

    def display_text
      fmt_meta_text = meta_text
      object_text + (fmt_meta_text.empty? ? "" : " (#{fmt_meta_text})")
    end

    def meta_text
      self.links.collect{|link| 
        (link.metaq.empty? ? nil : link.metaq)      
      }.reject {|l| l.nil? }.join("; ")
    end

    def grouped_attribute(name)
      ((self.links.first && self.links.first.send(name)) || self.send(name))
    end
    
    def distinct_attribute(name)
      self.links.collect{|link|         
        ((link.send(name).nil? || link.send(name).empty?) ? nil : link.send(name))      
      }.reject {|l| l.nil? }.join(", ")
    end

    def method_missing(name, *args, &block)
      if @klass.method_defined?(name)
        if @klass.search_klass.meta_fields.include?(name.to_sym)
          distinct_attribute(name)
        else
          grouped_attribute(name)
        end
      else
        super(name, *args, &block)
      end
    end
  end
end
