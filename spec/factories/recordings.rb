# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recording do |f|
    f.work_wiki_link_text "A sample work"

    f.recording_date ""
    f.recording_location ""

    f.duration nil
    f.rythm nil

#  f.updated_by "anonymous"
  end
end
