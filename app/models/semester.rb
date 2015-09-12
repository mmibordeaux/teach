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
    teaching_modules.collect(&:student_hours).sum
  end

  def student_hours_cm
    teaching_modules.collect(&:hours_cm).sum.round(2)
  end

  def student_hours_td
    teaching_modules.collect(&:hours_td).sum.round(2)
  end

  def student_hours_tp
    teaching_modules.collect(&:hours_tp).sum.round(2)
  end

  def planned_student_hours_cm
    teaching_modules.collect(&:planned_student_hours_cm).sum.round(2)
  end

  def planned_student_hours_td
    teaching_modules.collect(&:planned_student_hours_td).sum.round(2)
  end

  def planned_student_hours_tp
    teaching_modules.collect(&:planned_student_hours_tp).sum.round(2)
  end

  def to_s
    "S#{number}"
  end

end
