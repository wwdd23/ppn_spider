#encoding: utf-8

require 'csv'

class XlsGen
  class << self
    def gen_head
      """
      <?xml version='1.0' encoding='utf-8' ?>
      <Workbook xmlns='urn:schemas-microsoft-com:office:spreadsheet'
        xmlns:o='urn:schemas-microsoft-com:office:office'
        xmlns:x='urn:schemas-microsoft-com:office:excel'
        xmlns:ss='urn:schemas-microsoft-com:office:spreadsheet'
        xmlns:html='http://www.w3.org/TR/REC-html40'>
      """
    end

    def gen_foot
      "</Workbook>"
    end

    def gen_sheet(name, content)
      content_body = "<Worksheet ss:Name='#{name}'><Table>"

      content.each do |row|
        content_body << "<Row>"
        row.each do |col|
          content_body << "<Cell><Data ss:Type='String'>#{col.class == String ? CGI.escapeHTML(col) : col}</Data></Cell>"
        end
        content_body << "</Row>"
      end

      content_body << "</Table></Worksheet>"
    end

    def gen(*argv)
      content_body = ''
      argv.each_with_index do |item, index|
        content_body << gen_sheet("Sheet#{index}", item)
      end

      gen_head + content_body + gen_foot
    end

    def convert_csv(*argv)
      content_body = ''
      argv.each_with_index do |item, index|
        content_body << gen_sheet("Sheet#{index}", CSV.parse(item))
      end

      gen_head + content_body + gen_foot
    end

    def get_type(param)
      case param.class
      when :Fixnum; return :Number
      else; return :String
      end
    end
  end
end
