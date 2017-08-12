class RidesController < ApplicationController

	def index
    	@thing = [1,2,3]
    	json_response(@thing)
	end
end
