json.array!(@commands) do |command|
  json.extract! command, :id
  json.url command_url(command, format: :json)
end
