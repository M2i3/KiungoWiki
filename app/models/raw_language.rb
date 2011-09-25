class RawLanguage
  include Mongoid::Document
  include Mongoid::Timestamps

  set_database :raw_db
#TODO: Re-enable some form of versioning most likely using https://github.com/aq1018/mongoid-history instead of the Mongoid::Versioning module
  #after_initialize :set_defaults

  field :language_id, :type => String
  field :language_name_french, :type => String
  field :language_name_english, :type => String
  field :language_code, :type => String

  private 
  def set_defaults
  end
end
