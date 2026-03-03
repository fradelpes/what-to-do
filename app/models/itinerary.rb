class Itinerary < ApplicationRecord
  belongs_to :chat
  belongs_to :user

  has_many :events, dependent: :destroy
end
