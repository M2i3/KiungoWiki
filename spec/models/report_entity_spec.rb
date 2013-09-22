require 'spec_helper'

describe ReportEntity do
  [:name, :email, :phone, :details].each do |field|
    it { should validate_presence_of(field) }
  end
  # ['plainaddress',
  # "#@%^%#$@#$@#.com",
  # '@example.com',
  # 'Joe Smith <email@example.com>',
  # 'email.example.com',
  # 'email@example@example.com',
  # '.email@example.com',
  # 'email.@example.com',
  # 'email..email@example.com',
  # 'あいうえお@example.com'].each do |email|
  #   it { should_not validate_format_of(:email).to_allow(email) }
  # end
end