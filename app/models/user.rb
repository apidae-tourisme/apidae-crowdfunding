class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :trackable, :validatable, :omniauthable

  def self.from_omniauth(auth)
    usr = User.where(provider: auth.provider, email: auth.info.email).first_or_create do |user|
      user.password = Devise.friendly_token[0,20]
    end
    usr.save!
    usr
  end
end
