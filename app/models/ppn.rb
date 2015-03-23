class PPN

  def self.parse
    f = File.open(File.dirname(__FILE__) + '/ppn.html')
    doc = Nokogiri::HTML(f)
    f.close
    objects = []

    # teaching_subject
    subjects = []
    doc.css('.element .name').each do |category|
      subjects.push category.content
    end
    subjects.uniq!

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
            teaching_module[:howto] = nodes.collect(&:content).join(' ')
          when 'Compétences visées'
            competencies = []
            if nodes.count == 1
              competency = nodes.first.content
              competency.sub!('Être capable de ', '')
              competency.sub!('Être capable d\'', '')
              competencies << competency
            else
              ul = nodes.pop
              ul.css('li').each do |li|
                competencies.push li.content
              end
            end
            teaching_module[:competencies] = competencies
        end
      end
      teaching_module[:hours] = full_data.css('.total').first.content.to_i
      objects << teaching_module
    end
    objects
  end

end