namespace :kiungo do
  namespace :migration do
    desc "Migrate all the data from the Raw models to the application models"
    task :all=>:environment do

      unless Artist.count == 0 
        puts "There are already artists in the Artist model. Reloading is not possible."
      else
      params = {}
        RawArtist.all.entries.each do |rawArtist|
        params = {}
          Artist.disable_tracking { 
            params={:birth_location=>rawArtist.birth_location, 
                        :birth_date=>rawArtist.birth_date,
                        :death_location=>rawArtist.death_location, 
                        :death_date=>rawArtist.death_date,
                        :surname=>rawArtist.artist_surname,
                        :given_name=>rawArtist.artist_given_name,
                        :origartistid=>rawArtist.artist_id,
                        :is_group=>rawArtist.collective
            }
            unless ["0","",nil].include?(rawArtist.notes)
              params[:supplementary_sections]=[SupplementarySection.new({:title=>"Notes biographiques:",:content=>rawArtist.notes})]
            end
            Artist.create!(params)
          }
        end # rawArtists.each
        puts "rake stage 1 (artists) count=" + Artist.count.to_s
        RawLanguage.all.entries.each do |rawLanguage|

        Language.create!(:language_name_english=>rawLanguage.language_name_english,
                        :language_name_french=>rawLanguage.language_name_french, 
                        :language_code=>rawLanguage.language_code)
        end # rawLanguages.each
        puts "rake stage 2 (languages) count=" + Language.count.to_s

        RawCategory.all.entries.each do |rawCategory|
          Category.create!(:origcategoryid=>rawCategory.category_id,
                        :category_name=>rawCategory.category_name)
        end # RawCategories.each
        puts "rake stage 3 (categories) count=" + Category.count.to_s

        RawSupport.all.entries.each do |rawSupport|
        params = {}

          params = {:title=>rawSupport.support_title, 
                    :date_released=>rawSupport.date_released,
                    :media_type=>rawSupport.media_type,
                    :reference_code=>rawSupport.reference_code,
                    :number_of_recordings=>rawSupport.number_of_pieces,
                    :origalbumid=>rawSupport.support_id
                   }
          unless ["0","",nil].include?(rawSupport.notes)
            params[:supplementary_sections]=[SupplementarySection.new({:title=>"Notes:",:content=>rawSupport.notes})]
          end
          unless["0","",nil].include?(rawSupport.label_id)
            params[:label] = RawLabel.where(:label_id => rawSupport.label_id).first[:label_name]
          end
          Album.disable_tracking {
            params[:artist_wiki_links_text] = Artist.where(:origartistid=>rawSupport.artist_id).collect {|art|
               "oid:" + Artist.where(:origartistid => art[:origartistid]).first.id.to_s
              }.uniq.join(",")
            Album.create!(params)
          }
        end # rawSupports.each
        puts "rake stage 4 (albums) count=" + Album.count.to_s

        RawWork.all.entries.each do |rawWork|
          params = {}
          params = {:title=>rawWork.work_title, 
                    :date_written=>rawWork.date_written,
                    :lyrics=>rawWork.lyrics,
                    :origworkid=>rawWork.work_id,
                    :is_lyrics_verified=>rawWork.verified_text,
                    :is_credits_verified=>rawWork.verified_credits
                   }
          unless ["0","",nil].include?(rawWork.notes)
            params[:supplementary_sections]=[SupplementarySection.new({:title=>"Notes:",:content=>rawWork.notes})]
          end
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
          w = nil
          Work.disable_tracking {
            w = Work.create!(params)
          }

          RawRecording.where(:work_id=>rawWork.work_id).each do |rawRecording|
            params = {}
            params = {:recording_date=>rawRecording.recording_date, 
                      :duration=>rawRecording.duration,
                      :rythm=>rawRecording.rythm,
                      :work_wiki_link=>WorkWikiLink.new({:reference_text=>"oid:"+ w.id.to_s,:work_id=>w.id}),
                      :origrecordingid=>rawRecording.recording_id
                   }
            unless ["0","",nil].include?(rawRecording.notes)
              params[:supplementary_sections]=[SupplementarySection.new({:title=>"Notes:",:content=>rawRecording.notes})]
            end
            unless ["0","",nil].include?(rawRecording.category_id)
              params[:category_wiki_links_text] = RawCategory.where(:category_id => rawRecording.category_id).collect{|cc| "oid:"+Category.where(:origcategoryid => rawRecording.category_id).first.id.to_s}.uniq.join(",")
            end
            params[:artist_wiki_links_text] = RawRecordingArtistRoleLink.where(:recording_id=>rawRecording.recording_id).collect {|art|
               "oid:" + Artist.where(:origartistid => art[:artist_id]).first.id.to_s + " role:" + art.role}.uniq.join(",")

            params[:album_wiki_links_text] = RawRecordingSupportLink.where(:recording_id=>rawRecording.recording_id).collect {|art|
               "oid:" + Album.where(:origalbumid => art[:support_id]).first.id.to_s + " trackNb:" + art.track +
             " itemId:" + art.support_element_id + " itemSection:" + art.face
              }.uniq.join(",")
            Recording.disable_tracking {
              r = Recording.create!(params)
            }
            
          end # rawRecordings.each
        end # rawWorks.each
        puts "rake stage 5 (works/recordings) count=" + Work.count.to_s + "/" + Recording.count.to_s

        Album.disable_tracking {
          Album.all.entries.each do |album|
            params = {}
            params[:recording_wiki_links_text] = RawRecordingSupportLink.where(:support_id=>album.origalbumid).collect {|rsl|
               "oid:" + Recording.where(:origrecordingid => rsl[:recording_id]).first.id.to_s + " trackNb:" + rsl.track +
               " itemId:" + rsl.support_element_id + " itemSection:" + rsl.face
               }.uniq.join(",")
            params[:artist_wiki_links_text] = RawSupport.where(:support_id=>album.origalbumid).collect {|alb|
               "oid:" + Artist.where(:origartistid => alb[:artist_id]).first.id.to_s 
               }.uniq.join(",")
            album.update_attributes(params)
          end # Album.all.entries.each
        }
        puts "rake stage 6 (albums wiki links recording/artist)"
        puts "Before the big Work loop  work_count=" + Work.count.to_s
        Work.disable_tracking {
          Work.all.entries.each do |work2|
            params = {}
            params_original = {}
            params[:recording_wiki_links_text] = RawRecording.where(:work_id=>work2.origworkid).collect {|rr|
               "oid:" + Recording.where(:origrecordingid => rr[:recording_id]).first.id.to_s 
               }.uniq.join(",")

            #puts "Work id="+work2.id.to_s + "origworkid="+work2.origworkid.to_s+" rwl="+params[:recording_wiki_links_text].to_s

            originalworkid = RawWork.where(:work_id=>work2.origworkid).first.original_work_id
            #puts "origworkid = " + work2.origworkid + " originalworkid = " + originalworkid
            unless ["0","",nil].include?(originalworkid)
              original_work = Work.where(:origworkid => originalworkid).first
              if original_work
                #puts "Found originalwork"
                if original_work.language_code == work2.language_code
                  relation = "is_variant_from"
                  inverse_relation = "has_a_variant_work"
                else
                  relation = "is_translated_from"
                  inverse_relation = "has_a_translated_work"
                end
                params[:work_wiki_links_text] = RawWork.where(:work_id=>work2.origworkid).collect {|wl|
                   "oid:" + original_work.id.to_s + " relation:" + relation
                   }.uniq.join(",")
                #puts "work_wiki_links_text = " + params[:work_wiki_links_text].to_s
                params_original[:work_wiki_links_text] = RawWork.where(:work_id=>original_work.origworkid).collect {|wl|
                   "oid:" + work2.id.to_s + " relation:" + inverse_relation
                   }.uniq.join(",")
                original_work.update_attributes(params_original)
              else
                puts "none existing original work: " + originalworkid.to_s
              end
            end
            work2.update_attributes(params)
          end # Work.all.entries.each
        }
        puts "rake stage 7 (work wiki links recordings/works)"
        Artist.disable_tracking {
          Artist.all.entries.each do |artist1|
            params = {}
            params[:album_wiki_links_text] = RawSupport.where(:artist_id=>artist1.origartistid).collect {|sup|
               "oid:" + Album.where(:origalbumid => sup[:support_id]).first.id.to_s
               }.uniq.join(",")
            artist1.update_attributes(params)

          end # Artist.all.entries.each
          puts "rake stage 8"
          Artist.all.entries.each do |artist2|
            params = {}
            params[:work_wiki_links_text] = RawWorkArtistRoleLink.where(:artist_id=>artist2.origartistid).collect {|warl|
             "oid:" + Work.where(:origworkid => warl[:work_id]).first.id.to_s + (warl.role.nil? || warl.role.empty? ? "" : " role:" + warl.role)
               }.uniq.join(",")
            artist2.update_attributes(params)

          end # Artist.all.entries.each
          puts "rake stage 9"
          Artist.all.entries.each do |artist3|
            params = {}
            params[:recording_wiki_links_text] = RawRecordingArtistRoleLink.where(:artist_id=>artist3.origartistid).collect {|rarl|
               "oid:" + Recording.where(:origrecordingid => rarl[:recording_id]).first.id.to_s + (rarl.role.nil? || rarl.role.empty? ? "" : " role:" + rarl.role)
               }.uniq.join(",")
            #puts "Artist id="+artist3.id.to_s + "origartistid="+artist3.origartistid.to_s+" rwl="+params[:recording_wiki_links_text].to_s
            artist3.update_attributes(params)
          end # Artist.all.entries.each
        }
        puts "rake stage 10"
        Artist.disable_tracking {
          Recording.disable_tracking {
            Work.disable_tracking {
              Album.disable_tracking {
                Artist.all.each {|a|
                  a.work_wiki_links.each{|w| w.unset(:_type)}
                  a.artist_wiki_links.each{|w| w.unset(:_type)}
                  a.recording_wiki_links.each{|w| w.unset(:_type)} 
                  a.album_wiki_links.each{|w| w.unset(:_type)} 
                  a.timeless.save  
                }

                Recording.all.each {|a|
                  a.work_wiki_link.unset(:_type)
                  a.artist_wiki_links.each{|w| w.unset(:_type)}
                  a.album_wiki_links.each{|w| w.unset(:_type)}  
                  a.category_wiki_links.each{|w| w.unset(:_type)}  
                  a.timeless.save  
                }

                Work.all.each {|a|
                  a.work_wiki_links.each{|w| w.unset(:_type)}
                  a.artist_wiki_links.each{|w| w.unset(:_type)}
                  a.recording_wiki_links.each{|w| w.unset(:_type)}  
                  a.timeless.save  
                }

                Album.all.each {|a|
                  a.artist_wiki_links.each{|w| w.unset(:_type)}
                  a.recording_wiki_links.each{|w| w.unset(:_type)}  
                  a.timeless.save  
                }  
              }
            }
          }
        }
        puts "rake completed"
      end
    end
    desc "Migrate Albums into Releases"
    task albums: :environment do
      database = Release.collection.database
      ['db.albums.renameCollection("releases")',
        'db.possessions.update({}, {$rename:{ "album_id": "release_id" }}, { multi: true })',
        'db.portal_articles.update({"category": "album"}, {$set:{ "category": "release" }}, { multi: true })',
        'db.portal_articles.update({"featured_wiki_link._type":"AlbumWikiLink"}, 
        {$set: {"featured_wiki_link._type":"ReleaseWikiLink"}, $rename:{ "featured_wiki_link.album_id":"release_id" }},
        { multi: true })',
        'db.portal_articles.update({"featured_wiki_link._type":"AlbumArtistWikiLink"}, 
        {$set: {"featured_wiki_link._type":"ReleaseArtistWikiLink"}, $rename:{ "featured_wiki_link.album_id":"release_id" }},
        { multi: true })',
        'db.releases.update({"linkable._type":"AlbumArtistWikiLink"}, 
         {$set: {"linkable._type":"ReleaseArtistWikiLink"}, $rename:{ "linkable.album_id":"release_id" }},{ multi: true })',
        'db.changes.update({"scope":"album"},{$set: {"scope":"release"}},{ multi: true })',
        'db.releases.update({"linkable._type":"AlbumArtistWikiLink"}, 
        {$set: {"linkable._type":"ReleaseArtistWikiLink"}, $rename:{ "linkable.album_id":"release_id" }},
        { multi: true })',
        'db.recordings.update({},{$rename:{ "album_wiki_links":"release_wiki_links" }},{ multi: true })',
        'var newArray; var obj;db.recordings.find().forEach(function(doc){
          newArray = doc.release_wiki_links;
          if(newArray != undefined) {
            for(i = 0; i < newArray.length; i++) {
              obj = newArray[i];
              obj.release_id = obj.album_id;
              delete obj.album_id;
              printjson(obj);
              newArray[i] = obj;
            }
            doc.release_wiki_links = newArray;
          }
        })',
        'db.artists.update({},{$rename:{ "album_wiki_links":"release_wiki_links" }},{ multi: true })',
        'db.changes.drop()'
      ].each {|command| database.command eval: command }
    end
  end
end
