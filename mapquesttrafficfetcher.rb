require_relative "trafficfetcher"
require "nokogiri"

module TrafficFetcher
  class MapQuestTrafficFetcher < BaseFetcher
    BASE_LOCATION_URL = "http://www.mapquestapi.com/geocoding/v1/address?key="
    BASE_TRAFFIC_URL = "http://www.mapquestapi.com/traffic/v1/incidents?key="
    BOX_ADJUSTER = 0.25
    
    attr_reader :traffic_incidents
    
    def initialize(apikey)
      super()
      @apikey = apikey
      @traffic_incidents = Array.new
    end

    # TODO: return hash
    def fetch_by_zip_code(zip_code)
      fetch_bounding_box_by_zip_code(zip_code)
      http_request("#{BASE_TRAFFIC_URL}#{@apikey}&callback=handleIncidentsResponse&boundingBox=#{@bounding_box}&filters=construction,incidents&inFormat=kvp&outFormat=xml") do |body|
        xml_body = Nokogiri::XML.parse(body)
        xml_body.remove_namespaces!
        xml_body.xpath("//Incident").each do |ti|
          i = Incident.new
          i.type = ti.xpath('type').first.content
          i.severity = ti.xpath('severity').first.content
          i.description = ti.xpath('fullDesc').first.content
          @traffic_incidents << i
        end
      end
    end
    
    private
    
    def fetch_bounding_box_by_zip_code(zip_code)
      http_request("#{BASE_LOCATION_URL}#{@apikey}&callback=renderOptions&inFormat=kvp&outFormat=xml&location=#{zip_code}") do |body|
        xml_body = Nokogiri::XML.parse(body)
        xml_body.remove_namespaces!
        xml_body.xpath("//latLng").each do |bb|
          southLatitude = bb.xpath('lat').first.content.to_f - BOX_ADJUSTER
          westLongitude = bb.xpath('lng').first.content.to_f - BOX_ADJUSTER
          northLatitude = bb.xpath('lat').first.content.to_f + BOX_ADJUSTER
          eastLongitude = bb.xpath('lng').first.content.to_f + BOX_ADJUSTER
          @bounding_box = "#{northLatitude},#{westLongitude},#{southLatitude},#{eastLongitude}"
        end
      end
    end
     
  end
  
  class Incident
    attr_accessor :type, :severity, :roadclosed, :congestion, :description
  end
end