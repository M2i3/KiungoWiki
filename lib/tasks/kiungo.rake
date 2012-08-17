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
                        :origartistid=>rawArtist.artist_id,
                        :is_group=>rawArtist.collective,
                        :info=>rawArtist.notes)
        end # rawArtists.each
        puts "rake stage 1"
        RawLanguage.all.each do |rawLanguage|
          Language.create!(:language_name_english=>rawLanguage.language_name_english,
                        :language_name_french=>rawLanguage.language_name_french, 
                        :language_code=>rawLanguage.language_code)
        end # rawLanguages.each
        puts "rake stage 2"

        RawCategory.all.each do |rawCategory|
          Category.create!(:category_id=>rawCategory.category_id,
                        :category_name=>rawCategory.category_name)
        end # RawCategories.each
        puts "rake stage 3"

        RawSupport.all.each do |rawSupport|
          params = {:title=>rawSupport.support_title, 
                    :date_released=>rawSupport.date_released,
                    :media_type=>rawSupport.media_type,
                    :reference_code=>rawSupport.reference_code,
                    :number_of_recordings=>rawSupport.number_of_pieces,
                    :origalbumid=>rawSupport.support_id,
                    :info=>rawSupport.notes}
          unless["0","",nil].include?(rawSupport.label_id)
            params[:label] = RawLabel.where(:label_id => rawSupport.label_id).first[:label_name]
          end
          params[:artist_wiki_links_text] = Artist.where(:origartistid=>rawSupport.artist_id).collect {|art|
               "oid:" + Artist.where(:origartistid => art[:origartistid]).first.id.to_s
              }.uniq.join(",")
          Album.create!(params)
        end # rawSupports.each
        puts "rake stage 4"

        RawWork.all.each do |rawWork|
          params = {:title=>rawWork.work_title, 
                    :date_written=>rawWork.date_written,
                    :lyrics=>rawWork.lyrics,
                    :origworkid=>rawWork.work_id,
                    :is_lyrics_verified=>rawWork.verified_text,
                    :is_credits_verified=>rawWork.verified_credits,
                    :info=>rawWork.notes}
          unless ["0","",nil].include?(rawWork.language_id)
            params[:language_code] = RawLanguage.where(:language_id => rawWork.language_id).first[:language_code]
          end
          
          lwe = RawWorkEditorLink.where(:work_id => rawWork.work_id)
          unless lwe.first == nil 
            lwe.each do |lwe_i|
              e = RawEditor.where(:editor_id => lwe_i[:editor_id])
              unless e.first == nil
                params[:publisher] = e.first[:editor_name]
              end
            end
          end
          params[:artist_wiki_links_text] = RawWorkArtistRoleLink.where(:work_id=>rawWork.work_id).collect {|w|
               "oid:" + Artist.where(:origartistid => w[:artist_id]).first.id.to_s + " role:" + w.role
              }.uniq.join(",")
          w = Work.create!(params)
           
          RawRecording.where(:work_id=>rawWork.work_id).each do |rawRecording|

            params = {:recording_date=>rawRecording.recording_date, 
                      :duration=>rawRecording.duration,
                      :rythm=>rawRecording.rythm,
                      :category_id=>rawRecording.category_id,
                      :work_wiki_link=>WorkWikiLink.new({:reference_text=>"oid:"+ w.id.to_s,:work_id=>w.id}),
                      :origrecordingid=>rawRecording.recording_id,
                      :info=>rawRecording.notes}


              params[:artist_wiki_links_text] = RawRecordingArtistRoleLink.where(:recording_id=>rawRecording.recording_id).collect {|art|
               "oid:" + Artist.where(:origartistid => art[:artist_id]).first.id.to_s + " role:" + art.role
              }.uniq.join(",")

              params[:album_wiki_links_text] = RawRecordingSupportLink.where(:recording_id=>rawRecording.recording_id).collect {|art|
               "oid:" + Album.where(:origalbumid => art[:support_id]).first.id.to_s + " trackNb:" + art.track +
             " itemId:" + art.support_element_id + " itemSection:" + art.face
              }.uniq.join(",")
           
            r = Recording.create!(params)
            
          end # rawRecordings.each
        end # rawWorks.each
        puts "rake stage 5"

        Album.all.each do |album|
          params = {}
          params[:recording_wiki_links_text] = RawRecordingSupportLink.where(:support_id=>album.origalbumid).collect {|rsl|
             "oid:" + Recording.where(:origrecordingid => rsl[:recording_id]).first.id.to_s + " trackNb:" + rsl.track +
             " itemId:" + rsl.support_element_id + " itemSection:" + rsl.face
             }.uniq.join(",")
          params[:artist_wiki_links_text] = RawSupport.where(:support_id=>album.origalbumid).collect {|alb|
             "oid:" + Artist.where(:origartistid => alb[:artist_id]).first.id.to_s 
             }.uniq.join(",")
          album.update_attributes(params)
        end # Album.all.each
        puts "rake stage 6"

        Work.all.each do |work|
          params = {}
          params_original = {}
          params[:recording_wiki_links_text] = RawRecording.where(:work_id=>work.origworkid).collect {|rr|
             "oid:" + Recording.where(:origrecordingid => rr[:recording_id]).first.id.to_s 
             }.uniq.join(",")
          originalworkid = RawWork.where(:work_id=>work.origworkid).first.original_work_id
          puts "origworkid = " + work.origworkid + " originalworkid = " + originalworkid
          unless ["0","",nil].include?(originalworkid)
            original_work = Work.where(:origworkid => originalworkid).first
            if original_work
              #puts "Found originalwork"
              if original_work.language_code == work.language_code
                relation = "is_variant_from"
                inverse_relation = "has_a_variant_work"
              else
                relation = "is_translated_from"
                inverse_relation = "has_a_translated_work"
              end
              params[:work_wiki_links_text] = RawWork.where(:work_id=>work.origworkid).collect {|wl|
                 "oid:" + original_work.id.to_s + " relation:" + relation
                 }.uniq.join(",")
              puts "work_wiki_links_text = " + params[:work_wiki_links_text].to_s
              params_original[:work_wiki_links_text] = RawWork.where(:work_id=>original_work.origworkid).collect {|wl|
                 "oid:" + work.id.to_s + " relation:" + inverse_relation
                 }.uniq.join(",")
              original_work.update_attributes(params_original)
            else
              puts "none existing work"
            end
          end
          work.update_attributes(params)
        end # Work.all.each
        puts "rake stage 7"

        Artist.all.each do |artist1|
          params = {}
          params[:album_wiki_links_text] = RawSupport.where(:artist_id=>artist1.origartistid).collect {|sup|
             "oid:" + Album.where(:origalbumid => sup[:support_id]).first.id.to_s
             }.uniq.join(",")
          artist1.update_attributes(params)

        end # Artist.all.each
        puts "rake stage 8"
        Artist.all.each do |artist2|
          params = {}
          params[:work_wiki_links_text] = RawWorkArtistRoleLink.where(:artist_id=>artist2.origartistid).collect {|warl|
           "oid:" + Work.where(:origworkid => warl[:work_id]).first.id.to_s + (warl.role.nil? || warl.role.empty? ? "" : " role:" + warl.role)
             }.uniq.join(",")
          artist2.update_attributes(params)

        end # Artist.all.each
        puts "rake stage 9"
        Artist.all.each do |artist3|
          params = {}
          params[:recording_wiki_links_text] = RawRecordingArtistRoleLink.where(:artist_id=>artist3.origartistid).collect {|rarl|
             "oid:" + Recording.where(:origrecordingid => rarl[:recording_id]).first.id.to_s + " role:" + rarl.role
             }.uniq.join(",")
          artist3.update_attributes(params)

        end # Artist.all.each
        puts "rake completed"
      end
    end
  end
end
