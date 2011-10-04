class DataTest
  include Mongoid::Document
  field :age, :type=>Integer
field :looking_for, :type=>Range
end
