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
  def include?(record, field_name = @field_name)
    @values.include?(record[field_name])
  end
end

class PreviousDatabaseImporter
  DEFAULT_OPTIONS = { import_file: "/mnt/import/reference-chanson.mdb", 
                      artists_filter: FilterRecordAcceptAll.new,
                      work_filter: FilterRecordAcceptAll.new,
                      recording_filter: FilterRecordAcceptAll.new}
  def initialize(options = {})
    options = DEFAULT_OPTIONS.merge(options)
    @artist_filter = options[:artists_filter]
    @work_filter = options[:work_filter]
    @recording_filter = options[:recording_filter]
    @import_file = options[:import_file]
  end
  
  def import
    puts "creating the indexes to make sure everything runs faster"
    `rake db:mongoid:create_indexes`
    
    import_artists
    
    import_works
    import_works_artists
    import_work_publishers
    import_recordings    
    return true

    
    
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
        if @recording_filter.include?(l) and @work_filter.include?(l)
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
        end
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

  if false
    Dir.chdir("/mnt/import")
    (`mdb-tables -d ::: ./reference-chanson.mdb`).split(":::").collect{|t| t.strip }.select{|t| t != ""}.each {|t|
      `mdb-export -d ==FLD== -R ==REC== -D %Y-%m-%d -Q -H ./reference-chanson.mdb \"#{t}\" > /tmp/#{URI.escape(t)}.txt`
    }
  end
  
end

def do_import
    PreviousDatabaseImporter.new.wipe_all_data!
    artists_filter = FilterByField.new("RefArtiste", ["45", "466", "384", "95", "2405", "94"])
    work_filter = FilterByField.new("RefPiece",["32", "776", "873", "1016", "1017", "1018", "1019", "1020", "1021", "1022", "1023", "1024", "1025", "1026", "1027", "1028", "1029", "1030", "1031", "1032", "1033", "1034", "1035", "1036", "1037", "1038", "1039", "1040", "1041", "1042", "1044", "1045", "1046", "1047", "1048", "1049", "1050", "1051", "1052", "1053", "1054", "1055", "1056", "1057", "1058", "1059", "1060", "1061", "1062", "1063", "1064", "1065", "1066", "1067", "1069", "1070", "1071", "1072", "1073", "1074", "1075", "1076", "1077", "1078", "1079", "1080", "1081", "1082", "1083", "1084", "1085", "1086", "1087", "1089", "1090", "1091", "1092", "1093", "1094", "1256", "3859", "4047", "4048", "4049", "4050", "4783", "4786", "6930", "6932", "6933", "6934", "6935", "6936", "6938", "6939", "6940", "6941", "6942", "6944", "6945", "6946", "6947", "6948", "9471", "9692", "9693", "9707", "9708", "9709", "9711", "9712", "9713", "9714", "9742", "9753", "9754", "9755", "9756", "9757", "9758", "9806", "9807", "9838", "9839", "9840", "9841", "9907", "9908", "9909", "9910", "9990", "9991", "9992", "10021", "10022", "10023", "10024", "10025", "10026", "10027", "10028", "10029", "10030", "10043", "10044", "10045", "10046", "10047", "10048", "10049", "10050", "10051", "10052", "10053", "10054", "10055", "10056", "10057", "1043", "1068", "4785", "10031", "10032", "10033", "10034", "10035", "10036", "10037", "10038", "10039", "10040", "10041", "10042", "6937", "9710", "1014", "111", "848", "870", "973", "974", "975", "976", "977", "978", "979", "980", "981", "982", "983", "984", "985", "986", "987", "988", "989", "990", "991", "992", "993", "994", "995", "996", "997", "998", "999", "1000", "1001", "1002", "1003", "1004", "1005", "1006", "1007", "1008", "1009", "1010", "1011", "1012", "1013", "1015", "1317", "1363", "1368", "1384", "1417", "1512", "1615", "1688", "1944", "1999", "2104", "2132", "2159", "2268", "2271", "2272", "2297", "2312", "2318", "2324", "2426", "2435", "2437", "2461", "2463", "2491", "2556", "2586", "2592", "2595", "2615", "2700", "2715", "2717", "2718", "2814", "2822", "2833", "2839", "2842", "2919", "2963", "2981", "2987", "2994", "3078", "3143", "3172", "3185", "3197", "3214", "3227", "3263", "3273", "3275", "3343", "3347", "3353", "3513", "3548", "5084", "6727", "9299", "10020", "10096", "162", "163", "166", "167", "171", "738", "775", "797", "917", "950", "1365", "1410", "1479", "1494", "1607", "1689", "1716", "1723", "1752", "1847", "1896", "2025", "2097", "2145", "2228", "2244", "2307", "2340", "2428", "2605", "2607", "2880", "2907", "2970", "3354", "3546", "3588", "3623", "3685", "5001", "6244", "6374", "6951", "6954", "7282", "7286", "7289", "7463", "8345", "8359", "8375", "8530", "8536", "8537", "8770", "8892", "8896", "8904", "8905", "8910", "8913", "8920", "9119", "9120", "9121", "9122", "9129", "9132", "9133", "9467", "9470", "10063", "160", "164", "165", "168", "170", "668", "830", "844", "952", "960", "1374", "1503", "1524", "1530", "1540", "1730", "1844", "1849", "1850", "1855", "1884", "1886", "1887", "1894", "1895", "1897", "1898", "1899", "1900", "1903", "1908", "2077", "2129", "2499", "2587", "3137", "3181", "6949", "6953", "6955", "7281", "7798", "7937", "8691", "8771", "8842", "9217", "9303", "9328", "9330", "9336", "9340", "9345", "1792", "1904", "1906", "1907", "2072", "2126", "2249", "2254", "2447", "2522", "2708", "2764", "2786", "2835", "3364", "3415", "3479", "3494", "3754", "6103", "6242", "6247", "6248", "6249", "6377", "6506", "6950", "6957", "6971", "7279", "7283", "7284", "7285", "7288", "7290", "7291", "7292", "7558", "8886", "10545", "1517"])
    recording_filter = FilterByField.new("RefVersion",["1555", "1556", "1557", "1558", "1559", "1560", "1561", "1562", "1563", "1564", "1565", "1566", "1567", "1568", "1569", "1570", "1571", "1572", "1573", "1574", "1575", "1576", "1577", "1578", "1579", "1580", "1581", "1582", "1583", "1584", "1585", "1586", "1587", "1588", "1589", "1590", "1591", "1592", "1593", "1594", "1595", "1596", "1597", "1598", "1599", "1600", "1601", "1602", "1603", "1604", "1605", "1606", "1607", "1608", "1609", "1610", "1611", "1612", "1613", "1614", "1615", "1616", "1617", "1618", "1619", "1620", "1621", "1622", "1623", "1624", "1625", "1626", "1627", "1628", "1629", "1630", "1631", "1632", "1633", "1634", "1645", "1646", "1647", "1648", "1649", "1650", "1651", "1653", "1654", "1655", "1656", "1657", "1658", "1659", "1660", "1661", "1662", "1663", "6783", "6796", "8999", "9001", "9002", "9003", "9004", "9005", "9006", "9007", "9008", "9009", "9010", "9011", "9012", "9013", "9014", "9016", "9017", "9019", "9020", "9021", "9022", "9023", "9024", "11819", "12092", "12093", "12094", "12108", "12109", "12110", "12111", "12112", "12113", "12114", "12115", "12116", "12117", "12118", "12137", "12144", "12145", "12147", "12148", "12149", "12150", "12151", "12152", "12153", "12154", "12155", "12156", "12204", "12205", "12246", "12247", "12248", "12249", "12250", "12271", "12272", "12273", "12274", "12275", "12276", "12277", "12278", "12279", "12280", "12337", "12338", "12339", "12340", "12341", "12424", "12425", "12426", "12427", "12479", "12480", "12481", "12482", "12483", "12484", "12485", "12486", "12487", "12488", "12489", "12490", "12492", "12494", "12499", "12500", "12501", "12502", "12503", "12504", "12505", "12506", "12507", "12508", "12509", "12510", "12511", "12512", "12513", "12514", "12515", "12516", "12517", "12518", "12519", "12520", "12521", "12522", "12523", "12524", "12525", "12526", "12527", "12528", "12529", "919", "1059", "1249", "1510", "1511", "1513", "1514", "1515", "1516", "1517", "1518", "1519", "1520", "1521", "1522", "1523", "1524", "1525", "1526", "1527", "1528", "1529", "1530", "1531", "1532", "1533", "1534", "1535", "1536", "1537", "1538", "1539", "1540", "1541", "1542", "1543", "1544", "1545", "1546", "1547", "1548", "1549", "1550", "1551", "1552", "1553", "1554", "1902", "1949", "1955", "1970", "2004", "2103", "2209", "2282", "2521", "2576", "2642", "2687", "2717", "2745", "2861", "2864", "2865", "2892", "2907", "2914", "2921", "3030", "3039", "3041", "3069", "3071", "3102", "3171", "3201", "3207", "3210", "3231", "3320", "3336", "3338", "3339", "3442", "3450", "3461", "3467", "3571", "3615", "3633", "3638", "3645", "3740", "3806", "3839", "3853", "3865", "3881", "3896", "3937", "3948", "3952", "4020", "4021", "4025", "4037", "4203", "4242", "7452", "7546", "7565", "939", "1286", "1913", "2020", "2065", "2087", "2309", "2337", "2343", "2376", "2377", "2378", "2379", "2380", "2381", "2382", "2383", "2384", "2385", "2386", "2387", "2388", "2389", "2390", "2401", "2403", "2404", "2405", "2406", "2407", "2408", "2409", "2410", "2411", "2412", "2413", "2414", "2415", "2416", "2417", "2418", "2419", "2420", "2421", "2422", "2423", "2424", "2425", "2426", "2427", "2428", "2429", "2430", "2431", "2432", "2433", "2434", "2435", "2436", "2697", "2848", "2851", "2853", "3110", "3522", "3592", "3933", "3936", "3966", "3968", "3969", "4033", "4181", "4215", "4306", "4399", "6778", "6891", "8439", "9559", "9561", "9562", "9563", "9564", "9565", "9566", "9568", "9569", "9570", "9571", "10438", "10869", "11150", "11157", "11158", "11181", "11586", "11587", "11588", "11589", "11591", "11592", "11593", "11594", "11595", "11596", "11598", "11599", "861", "1254", "2109", "2201", "2288", "2557", "2657", "2809", "2849", "2883", "2939", "2940", "2941", "2942", "2943", "2944", "2945", "2946", "2947", "2948", "2949", "2950", "2951", "2952", "2953", "2954", "2955", "2956", "2977", "2978", "2979", "2980", "2981", "2982", "2983", "2984", "2985", "2986", "2987", "2988", "2989", "2990", "2991", "2992", "2993", "2994", "2995", "2996", "2997", "2998", "2999", "3000", "3001", "3002", "3003", "3004", "3005", "3007", "3008", "3009", "3098", "3458", "3734", "3814", "3844", "3955", "4224", "4352", "5582", "6118", "6567", "6749", "7149", "7152", "8297", "9423", "9424", "9425", "9426", "9427", "9428", "9429", "9430", "9431", "9432", "9433", "9434", "9435", "9436", "10069", "10646", "11332", "11689", "12251", "13206", "2363", "2364", "2365", "2366", "2367", "2368", "2369", "2370", "2371", "2372", "2373", "2374", "2375", "7359", "7363", "7542", "7634", "8095", "10140", "10417", "10447", "10509", "11139", "11149", "11156"])
    importer = PreviousDatabaseImporter.new(artists_filter: artists_filter, work_filter: work_filter, recording_filter: recording_filter)
    importer.import

end

if false
  load 'lib/mdb_importer.rb'
  do_import
end