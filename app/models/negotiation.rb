class Negotiation < ApplicationRecord
  belongs_to :agent
  has_many :negotiation_principals
  has_many :principals, through: :negotiation_principals

end
