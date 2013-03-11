# fix the following issue: https://github.com/mongoid/mongoid/issues/757
# TODO: remove after next upgrade
class Moped::BSON::ObjectId
  def to_xml(options)
    # Serialize Mongo object IDs as a string
    # (default uses a YAML representation)
    key = ActiveSupport::XmlMini::rename_key(options[:root], options)
    options[:builder].tag!(key, to_s)
  end
end
