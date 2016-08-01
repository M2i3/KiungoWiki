module WikiDocument
  extend ActiveSupport::Concern
  #TODO: Re-enable some form of versioning most likely using https://github.com/aq1018/mongoid-history instead of the Mongoid::Versioning module

  included do
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Search
    include Mongoid::History::Trackable
    
    field :signature, type:  String
    field :missing_supplementary_sections, type: Boolean
    
    # telling Mongoid::History how you want to track changes
    track_history   modifier_field: :modifier, # adds "referenced_in :modifier" to track who made the change, default is :modifier
                    version_field:  :version,   # adds "field :version, :type => Integer" to track current version, default is :version
                    track_create:     true,    # track document creation, default is false
                    track_update:     true,     # track document updates, default is true
                    track_destroy:    true     # track document destruction, default is false

    before_save :update_signature
    index({ signature: 1 }, { background: true })
    after_save :propate_changes_if_signature_changed
    
    scope :signed_as, ->(signature) {
      where(signature: signature.split("_").last)
    }
    
    embeds_many :supplementary_sections, class_name: "SupplementarySection", cascade_callbacks: true
    accepts_nested_attributes_for :supplementary_sections, allow_destroy: true
    validates_associated :supplementary_sections
    
    before_save :update_missing_supplementary_sections    
    index({ update_missing_supplementary_sections: 1 }, { background: true })
  end
  
  module ClassMethods
    def wiki_link_class
      (self.to_s + "WikiLink").constantize
    end
  end

  def to_wiki_link(klass=self.class.wiki_link_class, attributes = {})
#    attributes.merge!({searchref: self.to_search_query})
    klass.new {|wl|
      klass.wiki_link_fields.each {|k,attributes|
        wl[k] = self[k]
      }
      attributes.each {|k, value|
        wl[k] = value        
      }
    }
  end
  
  def to_search_query
    self.to_wiki_link.searchref
  end
  

  protected
  def update_signature
    @original_signature = self.signature
    self.signature = self.to_search_query.signature
    true
  end
  

  def propate_changes_if_signature_changed
    if @original_signature != self.signature
      propagate_changes
    end
  end
  
  def propagate_changes
    if self.class.wiki_link_class.respond_to?(:all_signed_as)
      me_wiki_link_attributes = self.to_wiki_link.attributes
      self.class.wiki_link_class.all_signed_as(@original_signature).each{|wl|
         wl.update_attributes(me_wiki_link_attributes)
         wl.save
      }
    end
  end
  
  def update_missing_supplementary_sections
    self.missing_supplementary_sections = self.supplementary_sections.length == 0
    true
  end

end