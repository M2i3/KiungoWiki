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

        RawCategory.all.each do |rawCategory|
          Category.create!(:category_id=>rawCategory.category_id,
                        :category_name=>rawCategory.category_name)
        end # RawCategories.each

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
            a = RawLinksRecordingArtistRole.where(:recording_id=>rawRecording.recording_id)
            unless a.count == 0
              art = RawArtist.where(:artist_id => a.first[:artist_id]).first
              art2 = Artist.where(:name => art[:artist_given_name]+" "+art[:artist_surname]).first
              unless art2 == nil
                params[:artist_wiki_link] = ArtistWikiLink.new({:reference=>art2.id,:name=>art2.name,:artist_id=>art2.id})
              end
            end
            s = RawLinksRecordingSupport.where(:recording_id=>rawRecording.recording_id)
            unless s.count == 0
              alb = RawSupport.where(:support_id => s.first[:support_id]).first
              alb2 = Album.where(:title => alb.support_title).first
              unless alb2 == nil
                params[:album_wiki_link] = AlbumWikiLink.new({:reference=>alb2.id,:title=>alb2.title,:album_id=>alb2.id})
              end
            end
           
            r = Recording.create!(params)
            
          end # rawRecordings.each
        end # rawWorks.each
      end
    end
  end
end
