class MessagesController < ApplicationController
  SYSTEM_PROMPT = <<~PROMPT
    You are a friendly travel assistant.

    IMPORTANT: You MUST collect at least 2 messages from the user before creating an itinerary.
    - First message: Ask for duration, budget, and interests if not all provided
    - Second message: Once you have all 3 parameters, create the itinerary

    Do NOT ask follow-up questions about specific regions or sites.
    Do NOT ask for clarification beyond the initial 2 messages.

    IMPORTANT: Even if the location is small or niche, you MUST generate activities.
    If you don't know specific activities in the location, create realistic, generic activities
    that match their interests and the location type.

    Once you have duration + budget + interests from at least 2 user messages, IMMEDIATELY:
    1. Create 2-6 specific activities based on their interests (minimum 2, maximum 6)
    2. For each activity, ensure it has: title, description, location, price, duration, category
    3. Call CreateItineraryTool with:
        - title: descriptive title
        - budget_max: their budget
        - duration_max: duration in MINUTES
        - events_json: JSON array MUST contain 2-6 activities, NEVER empty array.
          Example:
          [
            {"title": "Local Restaurant", "description": "Dining experience", "location": "City center", "price": 20, "duration": 120, "category": "food"},
            {"title": "Hiking Trail", "description": "Nature walk", "location": "Nearby forest", "price": 0, "duration": 180, "category": "nature"},
            ...
          ]

    CRITICAL RULES:
    - Require at least 2 messages from the user before creating an itinerary
    - events_json MUST NEVER be empty []
    - ALWAYS generate minimum 2 activities, maximum 6 activities
    - Create realistic activities even for small towns (hiking, local food, museums, markets, etc.)
    - Match activities to their interests and budget

    After the tool responds, say: "Votre itinéraire a été créé ! ID_ITINERARY:X"

    Be concise. Answer in French.
  PROMPT

  def create
    @chat = Chat.find(params[:chat_id])
    @message = @chat.messages.new(message_params)
    @message.role = "user"

    if @message.save
      # Compte le nombre de messages utilisateur
      user_message_count = @chat.messages.where(role: "user").count

      # Passe le contexte au tool via une variable de classe
      CreateItineraryTool.current_user = current_user
      CreateItineraryTool.current_chat = @chat

      @ruby_llm_chat = RubyLLM.chat.with_tool(CreateItineraryTool)
      build_conversation_history

      # Ajoute le contexte du nombre de messages au prompt
      custom_prompt = SYSTEM_PROMPT + "\n\nCONTEXT: This is message ##{user_message_count} from the user."

      response = @ruby_llm_chat.with_instructions(custom_prompt).ask(@message.content)

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
