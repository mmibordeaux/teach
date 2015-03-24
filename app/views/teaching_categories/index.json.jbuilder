json.array!(@teaching_categories) do |teaching_category|
  json.extract! teaching_category, :id, :label
  json.url teaching_category_url(teaching_category, format: :json)
end
