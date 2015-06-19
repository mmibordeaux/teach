# == Schema Information
#
# Table name: semesters
#
#  id         :integer          not null, primary key
#  number     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Semester < ActiveRecord::Base

  has_many :teaching_modules

  def student_hours
    student_hours = 0
    teaching_modules.each { |tm| student_hours += tm.student_hours }
    student_hours
  end

  def to_s
    "S#{number}"
  end

end
