json.array!(@teaching_modules) do |teaching_module|
  json.extract! teaching_module, :id, :code, :label, :objectives, :content, :how_to, :what_next, :hours, :semester_id, :teaching_subject_id, :teaching_unit_id, :teaching_category_id, :coefficient
  json.url teaching_module_url(teaching_module, format: :json)
end
