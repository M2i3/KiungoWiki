# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :recording do |f|
  f.recording_date ""
  f.recording_location ""
  f.duration "60"
  f.rythm "60"
end
