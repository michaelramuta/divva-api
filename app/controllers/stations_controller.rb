require 'net/http'
require 'json'

class StationsController < ApplicationController

	def index
    	url = 'https://data.cityofchicago.org/resource/aavc-b2wj.json'
		uri = URI(url)
		response = Net::HTTP.get(uri)
		stations = JSON.parse(response)

		stations.each do |station|
			new_station = Station.where(station_id: station['id']).first_or_initialize
			new_station.lat = station['latitude'].to_f
			new_station.lon = station['longitude'].to_f
			new_station.name = station['station_name']
			new_station.save
		end
    	
		json_response(Station.last)
	end
end



 

