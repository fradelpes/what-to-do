class CreateItineraryTool < RubyLLM::Tool
  description "Crée un itinéraire avec des activités pour l'utilisateur"

  param :title, type: :string, desc: "Titre de l'itinéraire"
  param :budget_max, type: :number, desc: "Budget max en euros"
  param :duration_max, type: :integer, desc: "Durée totale en minutes"
  param :events_json, type: :string, desc: "Liste des activités en format JSON"

  class << self
    attr_accessor :current_user, :current_chat
  end

  def execute(title:, budget_max:, duration_max:, events_json:)
    puts "DEBUG: events_json = #{events_json.inspect}"

    itinerary = Itinerary.create!(
      title: title,
      budget_max: budget_max,
      duration_max: duration_max,
      user: self.class.current_user,
      chat: self.class.current_chat
    )

    begin
      puts "DEBUG: Parsing JSON..."
      events = JSON.parse(events_json)
      puts "DEBUG: events parsed = #{events.inspect}"

      events.each do |event|
        puts "DEBUG: Creating event = #{event.inspect}"
        itinerary.events.create!(
          title: event["title"] || "Activité",
          description: event["description"] || "",
          location: event["location"] || "",
          price: event["price"].to_f,
          duration: event["duration"].to_i,
          category: event["category"] || "autre"
        )
      end
    rescue JSON::ParserError => e
      Rails.logger.error("JSON parsing error: #{e.message}")
      puts "DEBUG: JSON PARSE ERROR = #{e.message}"
    end

    itinerary.id.to_s
  end
end
