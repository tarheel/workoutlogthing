class CreateLogEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :log_entries do |t|
      t.belongs_to :user, index:true, foreign_key: true, null: false
      t.date :day, null: false
      t.text :details, null: false
    end
    add_index :log_entries, [:user_id, :day], unique: true
  end
end
