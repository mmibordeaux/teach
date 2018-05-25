json.year @promotion.to_s
json.projects @promotion.projects do |project|
  json.extract! project, :id, :label, :start_date, :description, :detailed_description
end