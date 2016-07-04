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
    
    scope :signed_as, ->(signature) {
      where(signature: signature.split("_").last)
    }
    
    embeds_many :supplementary_sections, class_name: "SupplementarySection", cascade_callbacks: true
    accepts_nested_attributes_for :supplementary_sections, allow_destroy: true
    validates_associated :supplementary_sections
    
    before_save :update_missing_supplementary_sections    
    index({ update_missing_supplementary_sections: 1 }, { background: true })
  end
  
  def update_signature
    self.signature = self.to_search_query.signature
    true
  end
  
  def update_missing_supplementary_sections
    self.missing_supplementary_sections = self.supplementary_sections.length == 0
    true
  end
   
end