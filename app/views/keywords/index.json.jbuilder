json.array!(@keywords) do |keyword|
  json.extract! keyword, :id, :label, :teaching_module_id
  json.url keyword_url(keyword, format: :json)
end
