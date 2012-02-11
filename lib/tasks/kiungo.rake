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
                        :surname=>rawArtist.artist_surname,
                        :given_name=>rawArtist.artist_given_name,
                        :origartistid=>rawArtist.artist_id)
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
                    :reference_code=>rawSupport.reference_code,
                    :origalbumid=>rawSupport.support_id}
          unless["0","",nil].include?(rawSupport.label_id)
            params[:label] = RawLabel.where(:label_id => rawSupport.label_id).first[:label_name]
          end
          params[:artist_wiki_links_text] = Artist.where(:origartistid=>rawSupport.artist_id).collect {|art|
               "oid:" + Artist.where(:origartistid => art[:origartistid]).first.id.to_s
              }.join(",")
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
          params[:artist_wiki_links_text] = RawLinksWorkArtist.where(:work_id=>rawWork.work_id).collect {|w|
               "oid:" + Artist.where(:origartistid => w[:artist_id]).first.id.to_s 
              }.join(",")
          w = Work.create!(params)
           
          RawRecording.where(:work_id=>rawWork.work_id).each do |rawRecording|

            params = {:title=>rawWork.work_title,
                      :recording_date=>rawRecording.recording_date, 
                      :duration=>rawRecording.duration,
                      :rythm=>rawRecording.rythm,
                      :work_wiki_link=>WorkWikiLink.new({:reference=>w.id,:title=>w.title,:work_id=>w.id}),
                      :origrecordingid=>rawRecording.recording_id}


              params[:artist_wiki_links_text] = RawLinksRecordingArtistRole.where(:recording_id=>rawRecording.recording_id).collect {|art|
               "oid:" + Artist.where(:origartistid => art[:artist_id]).first.id.to_s + " role:" + art.role_id
              }.join(",")

              params[:album_wiki_links_text] = RawLinksRecordingSupport.where(:recording_id=>rawRecording.recording_id).collect {|art|
               "oid:" + Album.where(:origalbumid => art[:support_id]).first.id.to_s
              }.join(",")
           
            r = Recording.create!(params)
            
          end # rawRecordings.each
        end # rawWorks.each

        Artist.all.each do |artist|
          params = {}
          params[:work_wiki_links_text] = RawLinksWorkArtist.where(:artist_id=>artist.origartistid).collect {|lwa|
             "oid:" + Work.where(:origworkid => lwa[:work_id]).first.id.to_s
             }.join(",")

          params[:album_wiki_links_text] = RawSupport.where(:artist_id=>artist.origartistid).collect {|art|
             "oid:" + Album.where(:origalbumid => art[:support_id]).first.id.to_s
             }.join(",")
          artist.update_attributes(params)
        end # rawArtists.each
      end
    end
  end
end
