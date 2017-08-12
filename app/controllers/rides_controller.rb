class RidesController < ApplicationController

	def index
		station_1_id = params[:station_1_id]
		station_2_id = params[:station_2_id]

		if station_1_id != station_2_id && params[:station_1_id].present? && params[:station_2_id].present?
			ride = Ride.where(station_1_id: station_1_id, station_2_id: station_2_id).first_or_initialize

			if ride.distance.nil?
				ride.distance = 1.1111
				ride.save
				json_response('updated')
			else
				json_response(ride)
			end
		else
			json_response('why')
		end
	end
end
