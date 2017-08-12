require 'net/http'
require 'json'

class RidesController < ApplicationController

	def index
		station_ids = params[:station_ids]

		if station_ids.nil?
			json_response('why')
		else
			station_pairs = station_ids.split('|').map{|e| e.split(',') }

			# first pass, make ride object or return distance
			rides = station_pairs.map do |station_pair|
				ride = Ride.where(station_1_id: station_pair[0], station_2_id: station_pair[1]).first_or_initialize
				ride.distance.nil? ? ride : {distance: ride.distance, station_1_id: ride.station_1_id, station_2_id: ride.station_2_id}
			end

			uncalculated_rides = rides.select{ |ride| ride.is_a?(Ride) }.uniq{|ride| [ride[:station_1_id], ride[:station_2_id]]}
			
			# calculate all unknown rides
			uncalculated_rides.each do |ride|
				station_1 = Station.find_by(station_id: ride.station_1_id)
				station_2 = Station.find_by(station_id: ride.station_2_id)

				if !station_1.nil? && !station_2.nil?
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
					end
				end
			end

			# map out all rides
			rides_distance = rides.map do |ride|
				ride.is_a?(Ride) ? {distance: Ride.where(station_1_id: ride.station_1_id, station_2_id: ride.station_2_id).first_or_initialize.distance, station_1_id: ride.station_1_id, station_2_id: ride.station_2_id}  : ride
			end

			json_response(rides_distance)
		end
	end
end
