class TeamsUsersController < ApplicationController
  before_action :require_logged_in

  def new
    @teams_user = TeamsUser.new
  end

  def create
    @teams_user = TeamsUser.new(
      user_id: current_user.id,
      team_id: Team.find_by_password(params.require(:teams_user).require(:team_password)).try(:id),
    )
    if @teams_user.save
      redirect_to root_path, notice: "You have joined #{@teams_user.team.name}."
    else
      puts @teams_user.errors.full_messages.first
      render :new
    end
  end

  def destroy
    teams_user = TeamsUser.where(user: current_user, team_id: params.require(:team_id)).first
    if teams_user && teams_user.destroy!
      redirect_to root_path, notice: "You have removed yourself from #{teams_user.team.name}."
    else
      redirect_to root_path, alert: 'Action failed.'
    end
  end
end
