class ReportEntity
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :name, :email,:details, :entity_url, :display_text, :entity_type

  validates_presence_of :name, :details, :entity_url, :display_text
  validates :email, presence: true,  format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }

  def initialize(attributes = {})
    unless attributes.nil?
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end
  end

  def persisted?
    false
  end
end