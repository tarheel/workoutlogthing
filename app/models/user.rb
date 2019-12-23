class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validate :check_team_password, on: :create
  validates_uniqueness_of :name

  has_many :teams_users
  has_many :teams, through: :teams_users

  after_create :join_team

  attr_accessor :team_password

  private

  def check_team_password
    if team_password.present? && !Team.find_by_password(team_password)
      errors[:base] << 'The team password is not valid. Leave this field blank if you don\'t
        already have a team.'.squish!
    end
  end

  def join_team
    if team_password.present?
      self.teams << Team.find_by_password(team_password)
    end
  end
end
