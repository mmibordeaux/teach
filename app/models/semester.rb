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

  def self.planned_teacher_hours_cm_costs
    all.collect(&:planned_teacher_hours_cm_costs).sum
  end

  def self.planned_teacher_hours_td_costs
    all.collect(&:planned_teacher_hours_td_costs).sum
  end

  def self.planned_teacher_hours_tp_costs
    all.collect(&:planned_teacher_hours_tp_costs).sum
  end

  def self.planned_teacher_hours_costs
    all.collect(&:planned_teacher_hours_costs).sum
  end

  # Expected

  def expected_student_hours
    teaching_modules.collect(&:expected_student_hours).sum
  end

  # Legacy methods, should be planned or expected

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

  # Planned

  def planned_student_hours
    teaching_modules.collect(&:planned_student_hours).sum
  end

  def planned_student_hours_cm
    teaching_modules.collect(&:planned_student_hours_cm).sum
  end

  def planned_student_hours_td
    teaching_modules.collect(&:planned_student_hours_td).sum
  end

  def planned_student_hours_tp
    teaching_modules.collect(&:planned_student_hours_tp).sum.round(2)
  end

  def planned_teacher_hours
    teaching_modules.collect(&:planned_teacher_hours).sum
  end

  def planned_teacher_hours_cm
    teaching_modules.collect(&:planned_teacher_hours_cm).sum
  end

  def planned_teacher_hours_td
    teaching_modules.collect(&:planned_teacher_hours_td).sum
  end

  def planned_teacher_hours_tp
    teaching_modules.collect(&:planned_teacher_hours_tp).sum.round(2)
  end

  # Costs

  def planned_teacher_hours_cm_costs
    teaching_modules.collect(&:planned_teacher_hours_cm_costs).sum
  end

  def planned_teacher_hours_td_costs
    teaching_modules.collect(&:planned_teacher_hours_td_costs).sum
  end

  def planned_teacher_hours_tp_costs
    teaching_modules.collect(&:planned_teacher_hours_tp_costs).sum
  end

  def planned_teacher_hours_costs
    teaching_modules.collect(&:planned_teacher_hours_costs).sum
  end

  def delta_student_hours
    planned_student_hours - expected_student_hours
  end

  def to_s
    "S#{number}"
  end

end
