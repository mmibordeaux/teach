json.array!(@projects) do |project|
  json.extract! project, :id, :label, :semester_id
  json.url project_url(project, format: :json)
end
