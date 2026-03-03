class ChatsController < ApplicationController
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
end
