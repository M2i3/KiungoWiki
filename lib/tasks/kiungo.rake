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
          params = {:title=>rawWork.work_title, 
                           :date_written=>rawWork.date_written,
                           :lyrics=>rawWork.lyrics,
                           :origworkid=>rawWork.work_id}
          unless ["0","",nil].include?(rawWork.language_id)
            params[:language_code] = RawLanguage.where(:language_id => rawWork.language_id).first[:language_code]
          end
          
          lwe = RawLinksWorkEditor.where(:work_id => rawWork.work_id)
          unless lwe.first == nil 
            lwe.each do |lwe_i|
              e = RawEditor.where(:editor_id => lwe_i[:editor_id])
              unless e.first == nil
                params[:publisher] = e.first[:editor_name]
              end
            end
          end
          w = Work.create!(params)
                     
          RawRecording.where(:work_id=>rawWork.work_id).each do |rawRecording|
            params = {:title=>rawWork.work_title,
                      :recording_date=>rawRecording.recording_date, 
                      :duration=>rawRecording.duration,
                      :rythm=>rawRecording.rythm,
                      :work_wiki_link=>WorkWikiLink.new({:reference=>w.id,:title=>w.title,:work_id=>w.id})}
            
            r = Recording.create!(params)
            
          end # rawRecordings.each
        end # rawWorks.each

        RawSupport.all.each do |rawSupport|
          params = {:title=>rawSupport.support_title, 
                    :date_released=>rawSupport.date_released,
                    :media_type=>rawSupport.media_type,
                    :reference_code=>rawSupport.reference_code}
          unless["0","",nil].include?(rawSupport.label_id)
            params[:label] = RawLabel.where(:label_id => rawSupport.label_id).first[:label_name]
          end
          Album.create!(params)
        end # rawSupports.each
      end
    end
  end
end
