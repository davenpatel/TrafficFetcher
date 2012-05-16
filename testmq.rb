require_relative 'mapquesttrafficfetcher'

mqtf = TrafficFetcher::MapQuestTrafficFetcher.new("Fmjtd%7Cluua2durl9%2C8a%3Do5-hrtah")
mqtf.fetch_by_zip_code(21201)
puts mqtf.traffic_incidents