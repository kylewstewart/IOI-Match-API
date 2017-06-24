class Negotiation < ApplicationRecord
  belongs_to :agent
  has_many :principals
  
end
