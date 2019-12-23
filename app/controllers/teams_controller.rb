class TeamsController < ApplicationController
  before_action :require_logged_in

  def new
    @team = Team.new
  end

  # # GET /teams/1/edit
  # def edit
  # end

  def create
    @team = Team.new(team_params)

    if @team.save
      current_user.teams << @team
      redirect_to root_path, notice: "You've successfully created and joined #{@team.name}."
    else
      render :new
    end
  end

  # # PATCH/PUT /teams/1
  # # PATCH/PUT /teams/1.json
  # def update
  #   respond_to do |format|
  #     if @team.update(team_params)
  #       format.html { redirect_to @team, notice: 'Team was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @team }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @team.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # def destroy
  #   @team.destroy
  #   respond_to do |format|
  #     format.html { redirect_to teams_url, notice: 'Team was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # def set_team
    #   @team = Team.find(params[:id])
    # end

    def team_params
      params.require(:team).permit(:name, :team_password, :confirm_team_password)
    end
end
