class MessagesController < ApplicationController
  SYSTEM_PROMPT = <<~PROMPT
    You are a friendly travel assistant for the app "What to Do?".

    The user is looking for activity suggestions and personalized itineraries.

    Help them by asking about their available time, budget, location and interests.
    Then suggest a concrete itinerary with activities, schedules and estimated prices.

    Answer concisely in French, using Markdown.
  PROMPT

  def create
    @chat = Chat.find(params[:chat_id])
    @message = @chat.messages.new(message_params)
    @message.role = "user"

    if @message.save
      @ruby_llm_chat = RubyLLM.chat
      build_conversation_history
      response = @ruby_llm_chat.with_instructions(SYSTEM_PROMPT).ask(@message.content)

      @chat.messages.create(role: "assistant", content: response.content)

      redirect_to chat_path(@chat)
    else
      redirect_to chat_path(@chat), alert: "Could not send message."
    end
  end

  private

  def build_conversation_history
    @chat.messages.each do |message|
      @ruby_llm_chat.add_message(message)
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
