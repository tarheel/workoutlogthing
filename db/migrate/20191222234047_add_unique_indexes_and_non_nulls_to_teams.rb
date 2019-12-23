class AddUniqueIndexesAndNonNullsToTeams < ActiveRecord::Migration[6.0]
  def change
    add_index :teams, :encrypted_password, unique: true
    add_index :teams, :name, unique: true
    change_column :teams, :encrypted_password, :string, null: false
    change_column :teams, :name, :string, null: false
  end
end
