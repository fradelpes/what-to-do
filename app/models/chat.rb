class Chat < ApplicationRecord
  belongs_to :user

  has_many :messages, dependent: :destroy
  has_one :itinerary, dependent: :destroy
end
