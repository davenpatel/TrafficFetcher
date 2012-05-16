require_relative "trafficfetcher"
require "nokogiri"

module TrafficFetcher
  class BingTrafficFetcher < BaseFetcher
    BASE_LOCATION_URL = "http://dev.virtualearth.net/REST/v1/Locations"
    BASE_TRAFFIC_URL = "http://dev.virtualearth.net/REST/v1/Traffic/Incidents"
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
      http_request("#{BASE_TRAFFIC_URL}/#{@bounding_box}?o=xml&key=#{@apikey}") do |body|
        xml_body = Nokogiri::XML.parse(body)
        xml_body.remove_namespaces!
        xml_body.xpath("//TrafficIncident").each do |ti|
          i = Incident.new
          i.type = ti.xpath('Type').first.content
          i.severity = ti.xpath('Severity').first.content
          i.roadclosed = ti.xpath('RoadClosed').first.content
          i.congestion = ti.xpath('CongestionInfo').first.content
          i.description = ti.xpath('Description').first.content
          @traffic_incidents << i
        end
      end
    end
    
    private
    
    def fetch_bounding_box_by_zip_code(zip_code)
      http_request("#{BASE_LOCATION_URL}?countryRegion=US&postalCode=#{zip_code}&key=#{@apikey}&o=xml") do |body|
        xml_body = Nokogiri::XML.parse(body)
        xml_body.remove_namespaces!
        xml_body.xpath("//BoundingBox").each do |bb|
          southLatitude = bb.xpath('SouthLatitude').first.content.to_f - BOX_ADJUSTER
          westLongitude = bb.xpath('WestLongitude').first.content.to_f - BOX_ADJUSTER
          northLatitude = bb.xpath('NorthLatitude').first.content.to_f + BOX_ADJUSTER
          eastLongitude = bb.xpath('EastLongitude').first.content.to_f + BOX_ADJUSTER
          @bounding_box = "#{southLatitude},#{westLongitude},#{northLatitude},#{eastLongitude}"
        end
      end
    end
     
  end
  
  class Incident
    attr_accessor :type, :severity, :roadclosed, :congestion, :description
  end
end