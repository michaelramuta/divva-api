require 'net/http'
require 'json'

class RidesController < ApplicationController

	def index
		station_1_id = params[:station_1_id]
		station_2_id = params[:station_2_id]
		station_1 = Station.find_by(station_id: station_1_id)
		station_2 = Station.find_by(station_id: station_2_id)

		if station_1.nil? || station_2.nil?
			json_response('why')
		else

			ride = Ride.where(station_1_id: station_1_id, station_2_id: station_2_id).first_or_initialize

			if ride.distance.nil?
				base_url = 'https://maps.googleapis.com/maps/api/distancematrix/json'
				location_parameters = '?origins=' + station_1.lat.to_s + ',' + station_1.lon.to_s + '&destinations=' + station_2.lat.to_s + ',' + station_2.lon.to_s
				additional_params = '&mode=bicyclingkey&units=imperial&key=' + ENV['GOOGLE_MAPS_KEY']
				uri = URI(base_url + location_parameters + additional_params)
				response = Net::HTTP.get(uri)
				result = JSON.parse(response)

				if result['status'] == 'OK'
					result['rows'].each_with_index do |row,i|
						row['elements'].each do |element,j|
							ride.distance = element['distance']['value'].to_f
							ride.save
						end
					end
					json_response(ride)
				else
					json_response('whoops')
				end
			else
				json_response(ride)
			end
			
		end
	end
end
