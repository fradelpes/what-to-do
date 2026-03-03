class MessagesController < ApplicationController
  def create
    @chat = Chat.find(params[:chat_id])
    @message = @chat.messages.new(message_params)
    @message.role = "user"

    if @message.save
      redirect_to chat_path(@chat)
    else
      redirect_to chat_path(@chat), alert: "Could not send message."
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
