json.array!(@semesters) do |semester|
  json.extract! semester, :id, :number
  json.url semester_url(semester, format: :json)
end
