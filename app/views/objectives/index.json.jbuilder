json.array!(@objectives) do |objective|
  json.extract! objective, :id, :label, :teaching_module_id
  json.url objective_url(objective, format: :json)
end
