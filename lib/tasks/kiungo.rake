namespace :kiungo do
  namespace :migration do
    desc "Migrate all the data from the Raw models to the application models"
    task :all=>:environment do

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

        RawLanguage.all.each do |rawLanguage|
          Language.create!(:language_name_english=>rawLanguage.language_name_english,
                        :language_name_french=>rawLanguage.language_name_french, 
                        :language_code=>rawLanguage.language_code)
        end # rawLanguages.each

        RawWork.all.each do |rawWork|
          if rawWork.language_id != "0" 
            if rawWork.language_id != ""
              l = RawLanguage.where(:language_id => rawWork.language_id).first
              Work.create!(:title=>rawWork.work_title, 
                          :date_written=>rawWork.date_written,
                          :language_code=>l[:language_code],
                          :lyrics=>rawWork.lyrics,
                          :origworkid=>rawWork.work_id)
            else
              Work.create!(:title=>rawWork.work_title, 
                           :date_written=>rawWork.date_written,
                           :lyrics=>rawWork.lyrics,
                           :origworkid=>rawWork.work_id)
            end
          end                       
          RawRecording.where(:work_id=>rawWork.work_id).each do |rawRecording|
            Recording.create!(:title=>rawWork.work_title,
                              :recording_date=>rawRecording.recording_date, 
                              :duration=>rawRecording.duration,
                              :rythm=>rawRecording.rythm,
                              :work_id=>rawRecording.work_id)
            
          end # rawRecordings.each
        end # rawWorks.each

        RawSupport.all.each do |rawSupport|
          Album.create!(:title=>rawSupport.support_title, 
                        :date_released=>rawSupport.date_released,
                        :label=>rawSupport.label_id, 
                        :media_type=>rawSupport.support_id,
                        :reference_code=>rawSupport.reference_code)
        end # rawSupports.each
      end
    end
  end
end
