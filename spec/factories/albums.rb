# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :album do |f|
    f.title "Mes meilleurs succes" # TODO UTF8 encoding
  end
end

