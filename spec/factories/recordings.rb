# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recording do
    work_wiki_link_text "A sample work"
    recording_date_text ""
    recording_location_text ""
    duration_text nil
    bpm_text nil
  end
end
