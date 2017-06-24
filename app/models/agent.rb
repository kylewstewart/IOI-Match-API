class Agent < ApplicationRecord
  has_secure_password

  has_many :sponserships
  has_many :principals, through: :sponserships
  has_many :negotiations

  def password=(password)
    self.password_digest = BCrypt::Password.create(password)
  end

  def is_password?(password)
    BCrypt::Password.new(self.password_digest) == password
  end

end
