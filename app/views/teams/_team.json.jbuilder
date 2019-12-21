json.extract! team, :id, :name, :encrypted_password, :created_at, :updated_at
json.url team_url(team, format: :json)
