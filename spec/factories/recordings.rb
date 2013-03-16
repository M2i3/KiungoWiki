# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recording do |f|
    f.work_wiki_link_text "A sample work"

    f.recording_date_text ""
    f.recording_location_text ""

    f.duration_text nil
    f.rythm_text nil

#  f.updated_by "anonymous"
  end
end
