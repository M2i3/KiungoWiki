require 'csv'

namespace :locale do
  desc "Export the locale files into a CSV file that can be viewed on a spreadsheet"
  task :export=>:environment do

    class LocaleInspector
      class << self
        def open_files(pattern)
          Dir[pattern].each do |f|
            yaml = YAML.load_file(f)
            inspect_content(f, yaml.first[1]) {|k,v|
              yield f, yaml.first[0], k, v
            }
          end
        end
    
        def inspect_hash(content)
          p content.inspect
          content.each {|pk,v|
            p 'START OF INSPECT HASH'
            p "pk: #{pk.inspect}\n"
            p "v: #{v.inspect}\n"
            p 'END OF INSPECT HASH'
            inspect_content(pk,v) {|k,v| yield [pk,k],v }
          }
        end
    
        def inspect_array(content)
          content.each_with_index {|v,i|
            inspect_content(i.to_s,v) {|k,v| yield [i.to_s,k],v }        
          }
        end
    
        def inspect_content(pk,content)
          inspector = case content
            when Hash
              :inspect_hash
            when Array
              :inspect_array
          end
          if inspector
            self.send(inspector,content) {|k,v| yield k,v}
          else
            raise
            yield pk, content
          end
        end
      end
    end

    locale_matrix = Hash.new {|h,k| h[k] = Hash.new}
    locales = Set.new
    LocaleInspector.open_files("./config/locales/**/*.yml") {|f,l,k,v|
      locale_matrix[k.flatten.reverse.join(".")][l] = v
      locales << l
      raise
    #  puts k.flatten.reverse.join(".") + ": " + v.to_s + " (#{v.class.to_s}) #{l}"
    }
    
    export_file = "/tmp/locale-#{Time.now}.csv"

    CSV.open(export_file, "wb", force_quotes: true) do |csv|
  
      csv << locales.to_a + ["class", "key"]
      
      locale_matrix.each {|k,v|
        row = []
        klass = nil
        locales.each {|l|
          row << v[l].to_s
          klass = v[l].class
        }
        row << klass.to_s
        row << k
        csv << row
      }
  
    end
    
    puts "Exported to #{export_file}"


  end
  task :import do
    # "not_authorized.headers", "not_authorized.messages", "admin_user_errors_warning.messages", "administration" # missing key
    s = Roo::Google.new "0Akn_zaMTt0NgdElPeVRxUVJXZUxYWUh2SVI3dGJ0eEE"#, user:"email@email.com", password:"password"
    en = {}
    fr = {}
    (s.first_row..s.last_row).each do |row|
      key = s.cell row, 4
      if key
        keys = key.split(".").reverse if key.include? "."
        en_value = s.cell row, 1
        fr_value = s.cell row, 2
        if keys
          en_marker = en
          fr_marker = fr
          keys.each_with_index do |k,i|
            if (i + 1) == keys.length
              en_marker[k] = en_value
              fr_marker[k] = fr_value
            else
              unless en_marker.has_key? k
                en_marker[k] = {}
                fr_marker[k] = {}
              end
            end
            if en_marker[k].is_a? Hash
              en_marker = en_marker[k]
              fr_marker = fr_marker[k]
            end
          end
        end
      end
      
    end
    
    def write_trans lang, trans
      trans = {lang => trans}
      File.open("#{Rails.root}/config/locales/app/#{lang}.yml", 'w') {|f| f.write(trans.to_yaml)}
    end
    
    write_trans "en", en
    write_trans "fr", fr
  end
end
