class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  attr_accessor :remember_token, :activation_token

  validates :name, presence: true, length:
    {maximum: Settings.user.name.max_length}
  validates :email, presence: true, length:
    {maximum: Settings.user.email.max_length},
     format: {with: VALID_EMAIL_REGEX},
     uniqueness: {case_sensitive: false}
  validates :password, presence: true, length:
    {minimum: Settings.user.password.min_length,
     maximum: Settings.user.password.max_length}
  validates :password, presence: true, length:
    {minimum: Settings.user.validates.minimum}, allow_nil: true

  before_save :downcase_email
  before_create :create_activation_digest

  scope :activated, ->{where activated: true}

  has_secure_password
  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute :remember_digest, nil
  end

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  private

  # Converts email to all lower-case.
  def downcase_email
    self.email = email.downcase
  end

  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
