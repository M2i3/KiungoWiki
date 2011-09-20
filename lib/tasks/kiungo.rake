namespace :kiungo do
  namespace :migration do
    desc "Migrate all the data from the Raw models to the application models"
    task :all do

      unless Artist.count == 0 
        puts "There are already artists in the Artist model. Reloading is not possible."

      else

        RawArtist.all.each do |rawArtist|
          Artist.create!(:birth_location=>rawArtist.birth_location, 
                        :birth_date=>rawArtist.birth_date,
                        :death_location=>rawArtist.death_location, 
                        :death_date=>rawArtist.death_date,
                        :name=>rawArtist.artist_given_name + " " + rawArtist.artist_surname)
        end # rawArtists.each

        RawWork.all.each do |rawWork|
          Work.create!(:title=>rawWork.work_title, 
                      :date_written=>rawWork.date_written,
                      :lyrics=>rawWork.lyrics,
                      :origworkid=>rawWork.work_id)

          RawRecording.where(:work_id=>rawWork.work_id).each do |rawRecording|
            puts "creating recording"
            Recording.create!(:recording_date=>rawRecording.recording_date, 
                             :duration=>rawRecording.duration,
                             :rythm=>rawRecording.rythm,
                             :work_id=>rawRecording.work_id)
          end # rawRecordings.each
        end # rawWorks.each
      end
    end
  end
end
