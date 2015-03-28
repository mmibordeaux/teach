json.array!(@fields) do |field|
  json.name field.label
  json.colour field.color
  json.size 1
  json.children do 
    json.array!(field.children) do |child|
      json.name child.label
      json.colour (child.color.nil? or child.color.empty?) ? field.color : child.color 
      json.size 1
    end
  end
end
