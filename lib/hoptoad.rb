require 'hoptoad/v2'

module Hoptoad
  class ApiVersionError < StandardError
    def initialize
      super "Wrong API Version: Expecting 2.0, 2.1, 2.2, 2.3 or 2.4"
    end
  end

  def self.parse_xml!(xml)
    parsed = ActiveSupport::XmlMini.backend.parse(escape_urls(xml))['notice'] || raise(ApiVersionError)
    processor = get_version_processor(parsed['version'])
    processor.process_notice(parsed)
  end

  private
    def self.get_version_processor(version)
      case version
      when /2\.[01234]/; Hoptoad::V2
      else;            raise ApiVersionError
      end
    end

    def self.escape_urls(xml_string)
      matches = xml_string.scan(/<url>http(?:s)?:\/\/([^<]+)<\/url>/) +
                  xml_string.scan(/"http(?:s)?:\/\/([^"]+)"/) +
                  xml_string.scan(/\shttp(?:s)?:\/\/([^\s]+)\s/)

      matches.flatten.each do |url|
        escaped_url = url.gsub(/&(?!amp;)/, '&amp;')
        xml_string.gsub!(url, escaped_url)
      end
      xml_string
    end
end

