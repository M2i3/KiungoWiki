# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :recording do |f|
  f.recording_date {DateTime.now}
  f.recording_location ""
  f.duration ""
  f.rythm ""
end
