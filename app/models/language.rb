class Language 
  include Mongoid::Document
  include Mongoid::Timestamps
#TODO: Re-enable some form of versioning most likely using https://github.com/aq1018/mongoid-history instead of the Mongoid::Versioning module
  #after_initialize :set_defaults

  field :language_id, :type => Integer
  field :language_name_french, :type => String
  field :language_name_english, :type => String
  field :language_code, :type => String

  validates_presence_of :language_id, :language_name_french, :language_name_english, :language_code
  validates_numericality_of :language_id

  private 
  def set_defaults
  end
end
