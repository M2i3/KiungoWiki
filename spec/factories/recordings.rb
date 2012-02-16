# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :recording do |f|
  f.work_title "A sample work"

  f.recording_date ""
  f.recording_location ""

  f.duration nil
  f.rythm nil

#  f.updated_by "anonymous"
end
