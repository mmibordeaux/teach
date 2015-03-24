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
      categories.push category.content
    end
    categories.uniq!

    # Training modules
    doc.css('.element').each do |m|
      teaching_module = Hash.new
      teaching_module[:code] = m.css('.id').first.content
      teaching_module[:label] = m.css('.name').first.content
      teaching_module[:semester_id] = m.css('.semvalue').first.content.to_i
      teaching_module[:teaching_unit_id] = m.css('.uevalue').first.content.to_i
      teaching_module[:teaching_subject] = m.css('.name').first.content
      teaching_module[:teaching_subject_id] = 'todo'
      teaching_module[:teaching_category] = m.css('.cat').first.content
      teaching_module[:teaching_category_id] = 'todo'
      teaching_module[:coefficient] = m.css('.coefvalue').first.content.to_i
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
            teaching_module[:objectives] = nodes.collect(&:content)
          when 'Contenus'
            teaching_module[:content] = nodes.collect(&:content).join(' ')
          when 'Modalités de mise en œuvre'
            teaching_module[:how_to] = nodes.collect(&:content).join(' ')
          when 'Prolongements possibles'
            teaching_module[:what_next] = nodes.collect(&:content).join(' ')
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
            teaching_module[:competencies] = competencies
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
            teaching_module[:keywords] = []
            keywords.each do |keyword| 
              teaching_module[:keywords] << keyword unless keyword.empty?
            end
          end
      end
      teaching_module[:hours] = full_data.css('.total').first.content.to_i
      objects << teaching_module
    end
    objects
  end

end