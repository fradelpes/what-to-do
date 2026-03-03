class ItinerariesController < ApplicationController

  def index
    @itineraries = Itinerary.all
  end
end
