require 'ostruct'

# M2i3WebBase
module M2i3WebBase
  module PageHelper
    # output the page title on the page and set the :title content for usage in the layout
    def title(text, header_text=nil)
      content_for :title, h(header_text || text)
      "<h1>#{h(text)}</h1>".html_safe
    end  


    def table_for(collection, options={})
      unless collection.empty?				
        klass = collection.first.class
        columns = options[:columns] || klass.column_names
        
        safe_concat('<table cellpadding="0" cellspacing="0"><thead><tr>')
        columns.each {|col|
          safe_concat("<th class=\"#{col.to_s}\">#{klass.human_attribute_name(col.to_s)}</th>")
        }
        safe_concat("</tr>\r</thead>")
        safe_concat('<tbody>')
        collection.each {|item|
          safe_concat('<tr>')
          
          formatted_item = OpenStruct.new

          columns.each {|col|
            formatted_item.send("#{col.to_s}=", h(item.send(col))) if item.respond_to?(col)
          }

          yield item, formatted_item if block_given?

          columns.each {|col|
           safe_concat("<td class=\"#{col.to_s}\">#{formatted_item.send(col)}</td>")
          }

          safe_concat("</tr>\r")
        }

        safe_concat("</tbody>\r")
        safe_concat('</table>')
      else
        safe_concat('<p class="empty_group">Nothing there...</p>')
      end



     
    end
  end
end
