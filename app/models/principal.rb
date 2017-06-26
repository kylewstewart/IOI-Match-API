class Principal < ApplicationRecord
  has_secure_password

  has_many :sponserships
  has_many :agents, through: :sponerships
  has_many :iois
  has_many :negotiation_principals
  has_many :negotiations, through: :negotiation_principals

  def password=(password)
    self.password_digest = BCrypt::Password.create(password)
  end

  def is_password?(password)
    BCrypt::Password.new(self.password_digest) == password
  end

end
