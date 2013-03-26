# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email "test@test.com"
    nickname "Tester Joe"
    password "testy123"
    password_confirmation "testy123"
  end
end
