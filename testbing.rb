require_relative 'bingtrafficfetcher'

btf = TrafficFetcher::BingTrafficFetcher.new("AvalOk5SRmDHUsFoYZqp6LJgdvLBU2K12N6l-YMlilEnpBKUmDnHARPXSbBZ4hBv")
btf.fetch_by_zip_code(21201)
puts btf.traffic_incidents