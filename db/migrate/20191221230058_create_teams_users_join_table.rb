class CreateTeamsUsersJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_table :teams_users do |t|
      t.references :team, index: false, null: false, foreign_key: true
      t.references :user, index: true, null: false, foreign_key: true
    end
    add_index :teams_users, [:team_id, :user_id], unique: true
  end
end
