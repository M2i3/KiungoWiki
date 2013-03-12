class RawWork
  include Mongoid::Document
  include Mongoid::Timestamps

#  set_database :raw_db

#TODO: Re-enable some form of versioning most likely using https://github.com/aq1018/mongoid-history instead of the Mongoid::Versioning module
  after_initialize :set_defaults

  field :work_title, :type => String
  field :date_written, :type => String
  field :work_id, :type => String
  field :original_work_id, :type => String
  field :notes, :type => String
  field :lyrics, :type => String
  field :verified_text, :type => String
  field :verified_credits, :type => String
  field :language_id, :type => String

  private 
  def set_defaults
  end
end
