class Team < ApplicationRecord
  extend OldPasswords

  has_and_belongs_to_many :users
  validates_uniqueness_of :name
  validates_uniqueness_of :encrypted_password
  validate :check_password_match
  before_save :set_encrypted_password

  attr_accessor :team_password
  attr_accessor :confirm_team_password

  def self.find_by_password(password)
    find_by_encrypted_password(encrypt_using_old_password(password))
  end

  private

  def check_password_match
    if team_password != confirm_team_password
      errors[:base] << 'The team password confirmation field didn\'t match the team password.'
    elsif team_password.empty? && !id
      errors[:base] << 'You must specify a team password.'
    end
  end

  def set_encrypted_password
    self.encrypted_password = self.class.encrypt_using_old_password(team_password) if team_password
  end
end
