json.array!(@teaching_subjects) do |teaching_subject|
  json.extract! teaching_subject, :id, :label, :teaching_unit_id
  json.url teaching_subject_url(teaching_subject, format: :json)
end
