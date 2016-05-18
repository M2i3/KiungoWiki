#
# Load the data from the previous database format
#
#
if false
  load 'lib/mdb_importer.rb'
  PreviousDatabaseImporter.new.wipe_all_data!
  PreviousDatabaseImporter.new.import
end


require 'uri'

class Progress
  def initialize(total)
    @total = total
    @current_count = 0
    @last_update_at = Time.now 
    @last_count_at = 0

  end
  def update_progress
    @current_count += 1
    @last_count_at += 1
    if (Time.now - @last_update_at) > 1.0 or @current_count == @totals
      performance = (@last_count_at / (Time.now - @last_update_at)).round(2)
      STDOUT.write "processing #{@current_count} of #{@total} (#{performance} items/second)                            \r"
      @last_update_at = Time.now
      @last_count_at = 0
    end
    
    if @current_count == @total
      STDOUT.write (" " * 80) + "\r" 
    end
  end
end

class MdbImporter
  def initialize(table_name, import_file="/mnt/import/reference-chanson.mdb")
    @table_name = table_name
    @import_file = import_file
  end
  
  def count
    unless @total_count  
      IO.popen("mdb-export -d ==FLD== -R ==REC== -D %Y-%m-%d -Q  \"#{@import_file}\" \"#{@table_name}\"") {|file|
        @total_count = file.read.split("==REC==").count - 1
      }
    end
    
    return @total_count
  end
  
  def each
    reset_progress
    headers = []
    IO.popen("mdb-export -d ==FLD== -R ==REC== -D %Y-%m-%d -Q  \"#{@import_file}\" \"#{@table_name}\"") {|file|
        
      file.read.split("==REC==").each do |line|
        if headers.empty?
          headers = line.split("==FLD==") 
        else

          yield Hash[headers.zip(line.split("==FLD=="))]
          update_progress
        end
      end
      
    }
    nil
  end
  
  protected
  def reset_progress
    @progress_counter = Progress.new(self.count)
  end
  def update_progress
    @progress_counter.update_progress
  end

end

class FilterRecordAcceptAll
  def include?(record)
    true
  end
end

class FilterByField
  def initialize(field_name = "", values = [])
    @field_name = field_name
    @values = values
  end
  def include?(record)
    @values.include?(record[@field_name])
  end
end

class PreviousDatabaseImporter
  DEFAULT_OPTIONS = { import_file: "/mnt/import/reference-chanson.mdb", 
                      artists_filter: FilterRecordAcceptAll.new}
  def initialize(options = {})
    options = DEFAULT_OPTIONS.merge(options)
    @artist_filter = options[:artists_filter]
    @work_filter = options[:work_filter]
    @import_file = options[:import_file]
  end
  
  def import
    puts "creating the indexes to make sure everything runs faster"
    `rake db:mongoid:create_indexes`
    
    import_artists
    
    import_works
    import_works_artists
    import_work_publishers
        
    return true

    
    import_recordings
    import_recordings_artists
        
  end
  
  def wipe_all_data!
    Artist.collection.drop
    Work.collection.drop
    Recording.collection.drop
    Release.collection.drop
  end

  def import_artists
    puts "Load the artists..."
    ::Artist.disable_tracking { 
      MdbImporter.new("Artistes").each{|l| 
        if @artist_filter.include?(l)
          params = {:origartistid => l["RefArtiste"],
                    :surname => l["NomArtiste"],
                    :given_name => l["PrenomArtiste"],
                    :birth_date => l["DateNaissance"],
                    :birth_location => l["LieuNaissance"],
                    :death_date => l["DateDeces"],
                    :death_location => l["LieuDécès"],
                    :is_group => l["Collectif"] }
              
          unless ["0","",nil].include?(l["Remarques"])
            params[:supplementary_sections] = [SupplementarySection.new({:title=>"Notes biographiques",:content=>l["Remarques"]})]
          end
          ::Artist.create!(params)
        end
      }
    }
    puts "... #{::Artist.count} artist(s) loaded"
  end
  
  def import_works
    puts "Load the works..."
    ::Work.disable_tracking {
      MdbImporter.new("Pieces").each{|l|
        if @work_filter.include?(l)
          params = {:origworkid => l["RefPiece"],
                    :title => l["Titre"],
                    :date_written => l["Annee"],
                    :language_code => l["RefLangue"],
                    :is_lyrics_verified => l["TexteVerifie"],
                    :is_credits_verified => l["CreditsVerifie"],
                    :ref_piece_originale => l["RefPieceOriginale"]}

          unless ["0","",nil].include?(l["Texte"])
            params[:lyrics] = l["Texte"]
          end
              
          unless ["0","",nil].include?(l["Remarque"])
            params[:supplementary_sections] = [SupplementarySection.new({:title=>"Notes",:content=>l["Remarque"]})]
          end
       
          ::Work.create!(params) 
        end
      }      
    }
    puts "... #{::Work.count} works(s) loaded"
  end
  
  def import_work_publishers
    puts "Load the publishers for the works..."
    ::Work.disable_tracking {
      MdbImporter.new("Lien Editeur Piece").each{|l|
        if @work_filter.include?(l)
          if w = Work.where(:origworkid => l["RefPiece"]).extras(:hint => {:origworkid => 1}).limit(1).first
            w.publishers << self.publishers[l["RefEditeur"]]
            w.save!
          end
        end
      }     
    }
    puts "... publishers loaded"
  end
  
  def import_works_artists
    puts "Load the relations between the artist and their work"
    
    ::Work.disable_tracking {
      ::Artist.disable_tracking {
        artists_works = Hash.new{|h,k|  h[k]=[]}
        works_artists = Hash.new{|h,k|  h[k]=[]}
        
        puts "pre-loading to speed up updates (1 of 3)"
        MdbImporter.new("Lien Artiste Auteur-compositeur").each{|l|
          if @work_filter.include?(l) and @artist_filter.include?(l)
            artists_works[l["RefArtiste"]] << {ref: l["RefPiece"], role: l["RefRole"]}
            works_artists[l["RefPiece"]] << {ref: l["RefArtiste"], role: l["RefRole"]}
          end
        }
        
        puts "processing the #{works_artists.count} works (2 of 3)"
        progress = Progress.new(works_artists.count)
        works_artists.each{|workid, artist_roles|
          w = Work.where(:origworkid => workid).first || raise("Cannot find work for id #{workid}")
          artists = {}.tap {|h| 
            # .extras(:hint => {:origartistid => 1})
            Artist.where(:origartistid.in => (artist_roles.collect{|a| a[:ref]})).each {|a|
              h[a.origartistid] = a
            }
          } 
                    
          awls = artist_roles.collect {|artist|
            a = artists[artist[:ref]] || raise("Cannot find artist for id #{artistid}")            
            a.to_wiki_link(WorkArtistWikiLink, {role: self.roles[artist[:role]]})
          }
          w.artist_wiki_links = awls
          w.save!
          progress.update_progress
        }
        
        
        puts "processing the #{artists_works.count} artists (3 of 3)"
        progress = Progress.new(artists_works.count)
        artists_works.each{|artistid,work_roles|
          a = Artist.where(:origartistid => artistid).extras(:hint => {:origartistid => 1}).first || raise("Cannot find artist for id #{artistid}")            
          
          works = {}.tap {|h| 
            Work.where(:origworkid.in => (work_roles.collect{|w| w[:ref]})).extras(:hint => {:origworkid => 1}).each {|w|
              h[w.origworkid] = w
            }
          } 
          
          awls = work_roles.collect {|work|
            w = works[work[:ref]] || raise("Cannot find work for id #{workid}")
            w.to_wiki_link(ArtistWorkWikiLink, {role: self.roles[work[:role]]})
          }
          a.work_wiki_links = awls
          a.save!
          progress.update_progress
        }        
      }
    }
    
    puts "... relations loaded"
  end
  
  def import_recordings
    puts "Load the recordings..."
    
    ::Recording.disable_tracking {
      MdbImporter.new("Versions").each{|l|
        #.extras(:hint => {:origworkid => 1})
        work = Work.where(:origworkid => l["RefPiece"]).limit(1).first
        
        params = {:origrecordingid => l["RefVersion"],
                  :recording_date => l["Annee"],
                  :duration => l["Duree"],
                  :work_wiki_link_text => work.to_wiki_link.reference_text
                }
       
     #       field :publishers, type: Array, default: []
       
        unless ["0","",nil].include?(l["Remarque"])
          params[:supplementary_sections] = [SupplementarySection.new({:title=>"Notes",:content=>l["Remarque"]})]
        end
        
        #field :rythm, type:  Integer

      	#[RefCategorieMusicale]			Long Integer, 
      	#[RefRythme]			Long Integer,         
       
        ::Recording.create!(params) 
      }      
    }
    
    puts "... #{::Recording.count} recording(s) loaded"
  end
  
  def import_recordings_artists
    puts "Load the relations between the artist and their recording"
    
    ::Recording.disable_tracking {
      ::Artist.disable_tracking {
        MdbImporter.new("Lien Artiste Interprete").each{|l|
          r = Recording.where(:origrecordingid => l["RéfVersion"]).first || raise("Cannot find recording for id #{l["RéfVersion"]}")
          a = Artist.where(:origartistid => l["RefArtiste"]).first || raise("Cannot find artist for id #{l["RefArtiste"]}")
          
          awl = a.to_wiki_link(RecordingArtistWikiLink)
          awl.role = self.roles[l["RefRole"]]
          r.artist_wiki_links << awl
          r.save!
          
          rwl = r.to_wiki_link(ArtistRecordingWikiLink)
          rwl.role = self.roles[l["RefRole"]]
          a.recording_wiki_links << rwl
          a.save!
        }
      }
    }
    
    puts "... relations loaded"
  end
  
  #
  # All the reference tables we need in different locations (loaded on demand)
  #
  class << self
    def set_reference_table(logical_name, table_name, lookup_column, value_column)
      class_eval <<-EOM
      def #{logical_name}
        unless @#{logical_name}
          @#{logical_name} = Hash.new {|h,k| h[k] = "Missing #{table_name} ID " + k.to_s}
          MdbImporter.new("#{table_name}").each{|v| @#{logical_name}[v["#{lookup_column}"]] = v["#{value_column}"] }
        end
        @#{logical_name}
      end
      EOM
    end
  end
  
  set_reference_table(:publishers, "Éditeurs", "RefEditeur", "NomEditeur")
  set_reference_table(:labels, "Étiquettes", "RefEtiquette", "NomEtiquette")
  set_reference_table(:roles, "Roles", "RefRole", "Role")
  set_reference_table(:rythmes, "Rythmes", "RefRythme", "Rythme")
end
if __FILE__==$0

  Dir.chdir("/mnt/import")
  (`mdb-tables -d ::: ./reference-chanson.mdb`).split(":::").collect{|t| t.strip }.select{|t| t != ""}.each {|t|
    `mdb-export -d ==FLD== -R ==REC== -D %Y-%m-%d -Q -H ./reference-chanson.mdb \"#{t}\" > /tmp/#{URI.escape(t)}.txt`
  }
  
  if false
    load 'lib/mdb_importer.rb'
    PreviousDatabaseImporter.new.wipe_all_data!
    artists_filter = FilterByField.new("RefArtiste", ["45", "466", "384", "95", "2405", "94"])
    work_filter = FilterByField.new("RefPiece",["32","776","873","1016","1017","1018","1019","1020","1021","1022","1023","1024","1025","1026","1027","1028","1029","1030","1031","1032","1033","1034","1035","1036","1037","1038","1039","1040","1041","1042","1044","1045","1046","1047","1048","1049","1050","1051","1052","1053","1054","1055","1056","1057","1058","1059","1060","1061","1062","1063","1064","1065","1066","1067","1069","1070","1071","1072","1073","1074","1075","1076","1077","1078","1079","1080","1081","1082","1083","1084","1085","1086","1087","1089","1090","1091","1092","1093","1094","1256","3859","4047","4048","4049","4050","4783","4786","6930","6932","6933","6934","6935","6936","6938","6939","6940","6941","6942","6944","6945","6946","6947","6948","9471","9692","9693","9707","9708","9709","9711","9712","9713","9714","9742","9753","9754","9755","9756","9757","9758","9806","9807","9838","9839","9840","9841","9907","9908","9909","9910","9990","9991","9992","10021","10022","10023","10024","10025","10026","10027","10028","10029","10030","10043","10044"])
    importer = PreviousDatabaseImporter.new(artists_filter: artists_filter, work_filter: work_filter)
    importer.import
#    importer.import_artists
#    importer.import_works
#    importer.import_works_artists
  end

   # MdbImporter.new("Étiquettes").each{|l| puts l.inspect }
  #  MdbImporter.new("Versions").each{|l| puts l.inspect }
  #  MdbImporter.new("Lien Editeur Piece").each{|l| puts l.inspect }
  
  # {"RefArtiste"=>"45", "NomArtiste"=>"Brel", "PrenomArtiste"=>"Jacques",
  # {"RefArtiste"=>"466", "NomArtiste"=>"Dion", "PrenomArtiste"=>"Céline",
  # {"RefArtiste"=>"384", "NomArtiste"=>"Dalida", "PrenomArtiste"=>"", 
  # {"RefArtiste"=>"95", "NomArtiste"=>"Delanoë", "PrenomArtiste"=>"Pierre", 
  # {"RefArtiste"=>"2405", "NomArtiste"=>"Compagnons de la chanson", "PrenomArtiste"=>"Les", 
  # {"RefArtiste"=>"94", "NomArtiste"=>"Bécaud", "PrenomArtiste"=>"Gilbert",
end