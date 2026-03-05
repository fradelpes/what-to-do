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
      events = JSON.parse(events_json)

      # SI L'IA N'A PAS GÉNÉRÉ D'ÉVÉNEMENTS, crée-les par défaut
      if events.empty?
        puts "DEBUG: events vide, génération par défaut"
        events = generate_default_events(budget_max)
      end

      events.each do |event|
        image_url = fetch_image_from_unsplash(event["title"])

        itinerary.events.create!(
          title: event["title"] || "Activité",
          description: event["description"] || "",
          location: event["location"] || "",
          price: event["price"].to_f,
          duration: event["duration"].to_i,
          category: event["category"] || "autre",
          image_url: image_url
        )
      end
    rescue JSON::ParserError => e
      Rails.logger.error("JSON parsing error: #{e.message}")
    end

    itinerary.id.to_s
  end

  private

  def generate_default_events(budget_max)
    # Génère des événements par défaut si l'IA n'en a pas créé
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
      },
      {
        "title" => "Promenade",
        "description" => "Balade à pied pour découvrir l'atmosphère locale",
        "location" => "Rues de la région",
        "price" => 0,
        "duration" => 120,
        "category" => "nature"
      }
    ]
  end

  def fetch_image_from_unsplash(query)
    require 'net/http'
    require 'json'

    api_key = ENV.fetch('UNSPLASH_API_KEY', nil)
    url = URI("https://api.unsplash.com/search/photos?query=#{ERB::Util.url_encode(query)}&client_id=#{api_key}&per_page=1")

    response = Net::HTTP.get_response(url)
    data = JSON.parse(response.body)

    if data['results'].any?
      data['results'].first['urls']['regular']
    else
      nil
    end
  rescue StandardError => e
    Rails.logger.error("Unsplash API error: #{e.message}")
    nil
  end
end
