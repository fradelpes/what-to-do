class ItinerariesController < ApplicationController

  def index
    @itineraries = Itinerary.order(created_at: :desc)
  end

  def show
    @itinerary = Itinerary.find(params[:id])
    @events = @itinerary.events
  end
end
