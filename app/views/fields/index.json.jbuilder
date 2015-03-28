json.array!(@fields) do |field|
  json.name field.label
  json.colour field.color
  json.children do 
    json.array!(field.children) do |child|
      json.name child.label
      json.colour child.color
      json.children do 
        json.array!(child.teaching_modules) do |teaching_module|
          json.name teaching_module.label
          json.colour child.color
        end
      end
    end
  end
end
