json.array!(@jobs) do |job|
  json.extract! job, :id, :label
  json.url job_url(job, format: :json)
end
