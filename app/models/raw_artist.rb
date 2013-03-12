class RawArtist 
  include Mongoid::Document
  include Mongoid::Timestamps

#  set_database :raw_db
#TODO: Re-enable some form of versioning most likely using https://github.com/aq1018/mongoid-history instead of the Mongoid::Versioning module
  #after_initialize :set_defaults

  field :artist_surname, :type => String
  field :artist_given_name, :type => String
  field :birth_date, :type => String
  field :birth_location, :type => String
  field :death_date, :type => String
  field :death_location, :type => String
  field :artist_id, :type => String
  field :collective, :type => String
  field :notes, :type => String

  private 
  def set_defaults
  end
end
