class TeamsUser < ApplicationRecord
  validate :check_team

  belongs_to :team
  belongs_to :user


  private

  def check_team
    if !team
      errors[:base] << 'Invalid team password.'
    elsif user && user.teams.include?(team)
      errors[:base] << "You're already a member of #{team.name}."
    end
  end
end
