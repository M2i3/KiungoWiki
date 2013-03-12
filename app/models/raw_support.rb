class RawSupport
  include Mongoid::Document
  include Mongoid::Timestamps

#  set_database :raw_db

#TODO: Re-enable some form of versioning most likely using https://github.com/aq1018/mongoid-history instead of the Mongoid::Versioning module
  after_initialize :set_defaults

  field :support_title, :type => String
  field :date_released, :type => String
  field :artist_id, :type => String
  field :media_type, :type => String
  field :category_id, :type => String
  field :number_of_pieces, :type => String
  field :reference_code, :type => String
  field :label_id, :type => String
  field :support_id, :type => String
  field :alpha_ordering, :type => String
  field :temporal_ordering, :type => String
  field :notes, :type => String

  private 
  def set_defaults
  end
end
