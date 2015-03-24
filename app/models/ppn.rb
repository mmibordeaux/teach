class PPN

  def self.parse
    f = File.open(File.dirname(__FILE__) + '/ppn.html')
    doc = Nokogiri::HTML(f)
    f.close
    objects = []

    (1..4).each do |index|
      Semester.find_or_create_by(number: index)
    end
    (1..2).each do |index|
      TeachingUnit.find_or_create_by(number: index)
    end

    # teaching_subject
    subjects = []
    doc.css('.element').each do |element|
      label = element.css('.name').first.content.to_s
      teaching_unit_number = element.css('.uevalue').first.content.to_i
      teaching_unit = TeachingUnit.where(number: teaching_unit_number).first
      TeachingSubject.find_or_create_by(label: label, teaching_unit_id: teaching_unit.id)
    end

    # teaching_category
    categories = []
    doc.css('.element .cat').each do |category|
      label = category.content.to_s
      TeachingCategory.find_or_create_by(label: label)
    end

    # Training modules
    doc.css('.element').each do |m|
      code = m.css('.id').first.content
      teaching_module = TeachingModule.find_or_create_by(code: code)
      teaching_module.label = m.css('.name').first.content
      teaching_module.semester_id = m.css('.semvalue').first.content.to_i
      teaching_unit_number = m.css('.uevalue').first.content.to_i
      teaching_unit = TeachingUnit.where(number: teaching_unit_number).first
      teaching_module.teaching_unit = TeachingUnit.where(number: teaching_unit_number).first
      teaching_subject_label = m.css('.name').first.content
      teaching_module.teaching_subject = TeachingSubject.where(label: teaching_subject_label, teaching_unit_id: teaching_unit.id).first
      teaching_category_label = m.css('.cat').first.content
      teaching_module.teaching_category = TeachingCategory.where(label: teaching_category_label).first
      teaching_module.coefficient = m.css('.coefvalue').first.content.to_i
      id = m.css('@href').first.content
      full_data = doc.css(id).first
      full_data.css('h3').each do |f|
        title = f.content
        nodes = []
        current = f.next_element
        while 
          nodes.push current
          current = current.next_element
          break if current.nil? or current.name == 'h3'
        end
        case title
          when 'Objectifs du module'
            nodes.collect(&:content).each do |objective_label|
              Objective.find_or_create_by(label: objective_label, teaching_module_id: teaching_module.id)
            end
            #teaching_module.objectives = nodes.collect(&:content)
          when 'Contenus'
            teaching_module.content = nodes.collect(&:content).join(' ')
          when 'Modalités de mise en œuvre'
            teaching_module.how_to = nodes.collect(&:content).join(' ')
          when 'Prolongements possibles'
            teaching_module.what_next = nodes.collect(&:content).join(' ')
          when 'Compétences visées'
            competencies = []
            if nodes.count == 1
              competency = nodes.first.content
              competency.gsub!('Être capable de ', '')
              competency.gsub!('Être capable d\'', '')
              competencies << competency
            else
              ul = nodes.pop
              ul.css('li').each do |li|
                competencies.push li.content
              end
            end
            # TODO
            #teaching_module[:competencies] = competencies
          when 'Mots-clés'
            list = nodes.collect(&:content).join(',')
            list.gsub!("\r\n", ' ')
            list.gsub!("\n", ' ')
            list.gsub!("\r", ' ')
            list.gsub!("
", ' ')
            list.gsub!(" ; ", ',')
            list.gsub!('…', ',')
            list.gsub!('.', ',')
            list.gsub!('                                    ', '')
            list.gsub!(',,', ',')
            list.gsub!(', ', ',')
            list.gsub!('—', ',')
            list.gsub!(', ', ',')
            list.downcase!
            keywords = list.split(',')
            #teaching_module[:keywords] = []
            keywords.each do |keyword| 
              # TODO
              #teaching_module[:keywords] << keyword unless keyword.empty?
            end
          end
      end
      teaching_module.hours = full_data.css('.total').first.content.to_i
      teaching_module.save
      objects << teaching_module
    end
    objects
  end

end