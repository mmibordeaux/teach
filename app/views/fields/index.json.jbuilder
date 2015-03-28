json.array!(@fields) do |field|
  json.name field.label
  json.colour field.color unless field.color.nil?
  json.children do 
    json.array!(field.children) do |child|
      json.name child.label
      json.colour child.color unless child.color.nil?
      json.children do 
        json.array!(child.teaching_modules) do |teaching_module|
          json.name teaching_module.label
          json.colour child.color unless child.color.nil?
        end
      end
    end
  end
end
