puts "Cleaning database..."
Message.destroy_all
Event.destroy_all
Itinerary.destroy_all
Chat.destroy_all
User.destroy_all

puts "Creating users..."
helene = User.create!(email: "helene@gmail.com", password: "123456")
zoe = User.create!(email: "zoe@gmail.com", password: "1234567")

puts "Creating chats and itineraries..."

# --- Helene ---
chat1 = Chat.create!(title: "Journée à Paris", user: helene)
itinerary1 = Itinerary.create!(title: "Journée à Paris", user: helene, chat: chat1, budget_max: 500, duration_max: 3)
chat1.update!(itinerary: itinerary1) # chat has_one itinerary

chat2 = Chat.create!(title: "Escapade Montagnarde", user: helene)
itinerary2 = Itinerary.create!(title: "Escapade Montagnarde", user: helene, chat: chat2, budget_max: 800, duration_max: 5)
chat2.update!(itinerary: itinerary2)

# --- Zoe ---
chat3 = Chat.create!(title: "Découverte de Lyon", user: zoe)
itinerary3 = Itinerary.create!(title: "Découverte de Lyon", user: zoe, chat: chat3, budget_max: 400, duration_max: 2)
chat3.update!(itinerary: itinerary3)

chat4 = Chat.create!(title: "Week-end Plage", user: zoe)
itinerary4 = Itinerary.create!(title: "Week-end Plage", user: zoe, chat: chat4, budget_max: 600, duration_max: 3)
chat4.update!(itinerary: itinerary4)

puts "Creating events..."

# Paris Adventure
Event.create!(title: "Musée du Louvre", category: "Culture", description: "Visite du musée", location: "Paris", price: 15, duration: 2, itinerary: itinerary1, image_url: "events/Louvre.jpg")
Event.create!(title: "Tour Eiffel", category: "Monument", description: "Balade au sommet", location: "Paris", price: 25, duration: 1, itinerary: itinerary1, image_url: "events/Tour_Eiffel.jpg")

# Mountain Escape
Event.create!(title: "Randonnée Alpes", category: "Outdoor", description: "Montée jusqu'au sommet", location: "Alpes", price: 0, duration: 5, itinerary: itinerary2, image_url: "events/Alpes.jpg")
Event.create!(title: "Dîner refuge", category: "Food", description: "Dîner typique", location: "Alpes", price: 30, duration: 2, itinerary: itinerary2, image_url: "events/Refuge.jpg")

# Lyon Explorer
Event.create!(title: "Vieux Lyon", category: "Culture", description: "Découverte des traboules", location: "Lyon", price: 0, duration: 2, itinerary: itinerary3, image_url: "events/Lyon.jpg")
Event.create!(title: "Basilique Fourvière", category: "Monument", description: "Visite panoramique", location: "Lyon", price: 5, duration: 1, itinerary: itinerary3, image_url: "events/Lyon2.jpg")

# Beach Trip
Event.create!(title: "Plage de Nice", category: "Relax", description: "Journée plage", location: "Nice", price: 0, duration: 3, itinerary: itinerary4, image_url: "events/Mer.jpg")
Event.create!(title: "Promenade des Anglais", category: "Sightseeing", description: "Balade en bord de mer", location: "Nice", price: 0, duration: 1, itinerary: itinerary4, image_url: "events/Promenade_Anglais.jpg")

puts "Creating messages..."

# Messages for chat1
Message.create!(chat: chat1, content: "Salut Helene ! Prête pour Paris ?", role: "user")
Message.create!(chat: chat1, content: "Oui ! J'ai hâte de visiter le Louvre 😃", role: "bot")

# Messages for chat2
Message.create!(chat: chat2, content: "On commence la randonnée demain ?", role: "user")
Message.create!(chat: chat2, content: "Oui, je te prépare l'itinéraire avec les points clés", role: "bot")

# Messages for chat3
Message.create!(chat: chat3, content: "Quelles activités à Lyon ?", role: "user")
Message.create!(chat: chat3, content: "Je te propose Vieux Lyon et la Basilique Fourvière", role: "bot")

# Messages for chat4
Message.create!(chat: chat4, content: "On va à la plage ?", role: "user")
Message.create!(chat: chat4, content: "Oui, voici l'itinéraire pour Nice avec les meilleurs spots", role: "bot")

puts "Finished! 🌟"
