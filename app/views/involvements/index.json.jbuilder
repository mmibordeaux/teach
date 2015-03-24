json.array!(@involvements) do |involvement|
  json.extract! involvement, :id, :project_id, :user_id, :hours
  json.url involvement_url(involvement, format: :json)
end
