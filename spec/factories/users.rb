# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email { "email#{rand(999999)}@example#{rand(999)}.com"}
    nickname { email.reverse }
    password "testy123"
    password_confirmation "testy123"
  end
end
