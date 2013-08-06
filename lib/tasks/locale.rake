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
          content.each {|pk,v|
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
end
