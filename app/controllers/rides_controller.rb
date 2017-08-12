require 'net/http'
require 'json'

class RidesController < ApplicationController

	def index
		stations_1_ids = params[:station_1_ids]
		stations_2_ids = params[:station_2_ids]

		if stations_1_ids.nil? || stations_2_ids.nil?
			json_response('why')
		else
			stations_1 = stations_1_ids.split(',')
			stations_2 = stations_2_ids.split(',')

			station_pairs = stations_1.zip(stations_2)

			# first pass, make ride object or return distance
			rides = station_pairs.map do |station_pair|
				ride = Ride.where(station_1_id: station_pair[0], station_2_id: station_pair[1]).first_or_initialize
				ride.distance.nil? ? ride : ride.distance
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
				ride.is_a?(Ride) ? Ride.where(station_1_id: ride.station_1_id, station_2_id: ride.station_2_id).first_or_initialize.distance : ride
			end

			json_response(rides_distance)
		end
	end
end
