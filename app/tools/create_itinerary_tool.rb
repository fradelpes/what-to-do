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
    itinerary = Itinerary.create!(
      title: title,
      budget_max: budget_max,
      duration_max: duration_max,
      user: self.class.current_user,
      chat: self.class.current_chat
    )

    begin
      events = if events_json.is_a?(String)
                 JSON.parse(events_json)
               else
                 events_json
               end

      if events.empty?
        events = generate_default_events(budget_max)
      end

      events.each do |event|
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
      default_events = generate_default_events(budget_max)
      default_events.each do |event|
        itinerary.events.create!(
          title: event["title"],
          description: event["description"],
          location: event["location"],
          price: event["price"].to_f,
          duration: event["duration"].to_i,
          category: event["category"]
        )
      end
    end

    "Itinéraire créé avec ID: #{itinerary.id}"
  end

  private

  def generate_default_events(budget_max)
    [
      {
        "title" => "Exploration locale",
        "description" => "Découvrir les sites principaux de la région",
        "location" => "Centre-ville",
        "price" => (budget_max * 0.3).round(2),
        "duration" => 120,
        "category" => "culture"
      },
      {
        "title" => "Restaurant local",
        "description" => "Déguster la cuisine régionale",
        "location" => "Centre-ville",
        "price" => (budget_max * 0.4).round(2),
        "duration" => 90,
        "category" => "food"
      }
    ]
  end
end
