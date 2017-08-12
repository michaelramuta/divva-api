class Ride < ApplicationRecord

	def self.format_distance(ride, distance=nil)
		if distance.nil?
			distance = Ride.where(station_1_id: ride.station_1_id, station_2_id: ride.station_2_id).first_or_initialize.distance
		end

		{distance: distance, station_1_id: ride.station_1_id, station_2_id: ride.station_2_id}
	end

end
