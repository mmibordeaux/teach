json.array!(@fields) do |field|
  json.name field.label
  json.colour field.color
  json.size field.hours
  json.children do 
    json.array!(field.children) do |child|
      json.name child.label
      json.colour child.color.nil? ? field.color : child.color 
      json.size child.hours
      json.children do 
        json.array!(child.teaching_modules) do |teaching_module|
          json.name teaching_module.label
          json.colour child.color.nil? ? field.color : child.color 
          json.size teaching_module.hours
        end
      end
    end
  end
end
