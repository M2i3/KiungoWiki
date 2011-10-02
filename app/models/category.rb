class Category 
  include Mongoid::Document
#TODO: Re-enable some form of versioning most likely using https://github.com/aq1018/mongoid-history instead of the Mongoid::Versioning module
  #after_initialize :set_defaults

  field :category_id, :type => Integer
  field :category_name, :type => String

  validates_presence_of :category_id, :category_name

  private 
  def set_defaults
  end
end
