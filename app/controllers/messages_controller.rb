class MessagesController < ApplicationController
  SYSTEM_PROMPT = <<~PROMPT
    You are a friendly travel assistant.

    When the user provides: duration, budget, and interests - you MUST immediately create their itinerary.

    Do NOT ask follow-up questions about specific regions or sites.
    Do NOT ask for clarification.

    If you have duration + budget + interests, IMMEDIATELY:
    1. Create 4-6 specific activities based on their interests
    2. Call CreateItineraryTool with:
      - title: descriptive title
      - budget_max: their budget
      - duration_max: duration in MINUTES
      - events_json: JSON array with activities like:
        [
          {"title": "Activity", "description": "Details", "location": "Place", "price": 10, "duration": 120, "category": "nature"},
          {"title": "Activity2", "description": "Details", "location": "Place", "price": 15, "duration": 90, "category": "nature"}
        ]

    After the tool responds, say: "Votre itinéraire a été créé ! ID_ITINERARY:X"

    Be concise. Answer in French.
  PROMPT

  def create
    @chat = Chat.find(params[:chat_id])
    @message = @chat.messages.new(message_params)
    @message.role = "user"

    if @message.save
      # Passe le contexte au tool via une variable de classe
      CreateItineraryTool.current_user = current_user
      CreateItineraryTool.current_chat = @chat

      @ruby_llm_chat = RubyLLM.chat.with_tool(CreateItineraryTool)
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
