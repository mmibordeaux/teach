json.array!(@competencies) do |competency|
  json.extract! competency, :id, :label, :teaching_module_id
  json.url competency_url(competency, format: :json)
end
