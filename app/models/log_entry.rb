class LogEntry < ApplicationRecord
  belongs_to :user, required: true
  validates :day, :details, presence: true
  validates :day, uniqueness: { scope: :user_id }
end
