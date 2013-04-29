# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :artist do
      name "MyString"
      surname "Surname"
      birth_date ""
      birth_location "MyString"
      death_date ""
      death_location "MyString"
    end
end