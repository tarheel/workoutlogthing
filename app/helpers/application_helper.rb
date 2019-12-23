module ApplicationHelper
  def leave_team_link(team, text)
    link_to text, delete_team_membership_path(team_id: team.id),
      method: :delete, data: { confirm: "Are you sure?" }
  end
end
