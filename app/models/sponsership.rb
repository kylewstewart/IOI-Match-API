class Sponsership < ApplicationRecord
  belongs_to :principal
  belongs_to :agent
  
end
