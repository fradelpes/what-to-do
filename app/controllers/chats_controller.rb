class ChatsController < ApplicationController
  def index
    @chats = Chat.all
  end
  def create
    @chat = Chat.new(user: current_user)
    if @chat.save
      redirect_to chat_path(@chat)
    else
      redirect_to root_path, alert: "Could not create chat."
    end
  end

  def show
    @chat = Chat.find(params[:id])
  end

  # def generate_itinerary
  #   @chat = Chat.find(params[:id])

  #   @itinerary = @chat.create_itinerary!(
  #     user: current_user,
  #     title: "Itinéraire généré"
  #   )
  #   redirect_to @itinerary
  # end
end
