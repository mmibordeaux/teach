json.array!(@teaching_units) do |teaching_unit|
  json.extract! teaching_unit, :id, :number
  json.url teaching_unit_url(teaching_unit, format: :json)
end
