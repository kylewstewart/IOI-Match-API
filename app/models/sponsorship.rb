class Sponsorship < ApplicationRecord
  belongs_to :principal
  belongs_to :agent

end
