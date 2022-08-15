# user model
class User < ApplicationRecord
  # frozen_string_literal: true
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  # devise :database_authenticatable,
  #:registerable,
  #        :recoverable, :rememberable, :validatable
  has_many :react_posts, dependent: :destroy
  has_many :replies, dependent: :destroy

  belongs_to :role, optional: true
  before_save :assign_role
  def assign_role
    self.role = Role.find_by name: 'Regular' if role.nil?
  end

  has_many :providers, dependent: :destroy
  has_many :microposts, dependent: :destroy # user huy thi micro cung huy
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id",
                                  dependent: :destroy

  has_many :passive_relationships, class_name: "Relationship",
                                   foreign_key: "followed_id",
                                   dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  # validates :password, presence: true, length: { minimum: 3 }
  scope :new_users, -> { where(created_at: 1.day.ago.beginning_of_day..1.day.ago.end_of_day) }
  class << self
    def digest(string)
      cost = if ActiveModel::SecurePassword.min_cost
          BCrypt::Engine::MIN_COST
        else
          BCrypt::Engine.cost
        end
      BCrypt::Password.create(string, cost: cost)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end

    def new_account(request, email)
      firt_name = request.env['omniauth.auth'][:info][:first_name]
      last_name = request.env['omniauth.auth'][:info][:last_name]
      full_name = firt_name + ' ' + last_name
      password = SecureRandom.hex(15)
      @user = User.new(email: email, name: full_name, activated: true, password: password)
      @user.save
    end
  end

  def readed_notification?
    read_notification == true
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  def session_token
    remember_digest || remember
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password?(token)
  end

  # def authenticated?(remember_token)
  #     digest = self.send("remember_digest")

  #     return false if remember_digest.nil?
  #     BCrypt::Password.new(remember_digest).is_password?(remember_token)
  # end

  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activates an account.
  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    # update_attribute(:reset_digest, User.digest(reset_token))
    # update_attribute(:reset_sent_at, Time.zone.now)
    update_columns(reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def feed
    # Micropost.where("user_id = ?", id)
    # Micropost.where("user_id IN (:following_ids) OR user_id = :user_id",
    #                following_ids: following_ids, user_id: id)
    following_ids = "SELECT followed_id FROM relationships
        WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
        OR user_id = :user_id", user_id: id)
  end

  def follow(other_user)
    following << other_user
  end

  # Unfollows a user.
  def unfollow(other_user)
    following.delete(other_user)
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

  def admin?
    role.name == 'Admin' unless role.nil?
  end

  private

  def downcase_email
    self.email = email.downcase
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
