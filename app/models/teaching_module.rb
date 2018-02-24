# == Schema Information
#
# Table name: teaching_modules
#
#  id                   :integer          not null, primary key
#  code                 :string
#  label                :string
#  content              :text
#  how_to               :text
#  what_next            :text
#  hours                :integer
#  semester_id          :integer
#  teaching_subject_id  :integer
#  teaching_unit_id     :integer
#  teaching_category_id :integer
#  coefficient          :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :integer
#  hours_cm             :integer
#  hours_td             :integer
#  hours_tp             :integer
#

class TeachingModule < ActiveRecord::Base

  belongs_to :teaching_unit
  belongs_to :teaching_subject
  belongs_to :teaching_category
  belongs_to :semester
  belongs_to :user
  has_many :objectives
  has_many :keywords
  has_many :fields_teaching_modules
  has_many :fields, through: :fields_teaching_modules
  has_many :projects, -> { uniq }, through: :fields
  has_many :involvements
  has_many :users_involved, through: :involvements
  
  accepts_nested_attributes_for :fields_teaching_modules, allow_destroy: true
  accepts_nested_attributes_for :fields

  default_scope { order('code') }

  def teacher_hours
    involvements.collect(&:teacher_hours).sum.round(2)
  end

  def student_hours
    involvements.collect(&:student_hours).sum.round(2)
  end

  def student_hours_delta
    return 0 if expected_student_hours.zero?
    result = 0
    unless hours == 0
      result = student_hours * 1.0 / hours * 1.0
    end
    (result - 1) * 100
  end

  def student_hours_above_threshold?
    return false if expected_student_hours.zero?
    student_hours_delta > 30
  end

  def student_hours_below_threshold?
    return false if expected_student_hours.zero?
    student_hours_delta < -30
  end

  # Expected student hours

  def expected_student_hours
    hours_cm + hours_td + hours_tp
  end

  # Planned student hours

  def planned_student_hours_cm
    involvements.collect(&:student_hours_cm).sum.round(2)
  end
  
  def planned_student_hours_td
    involvements.collect(&:student_hours_td).sum.round(2)
  end

  def planned_student_hours_tp
    involvements.collect(&:student_hours_tp).sum.round(2)
  end

  def planned_student_hours
    planned_student_hours_cm + planned_student_hours_td + planned_student_hours_tp
  end

  # Planned teacher hours

  def planned_teacher_hours_cm
    involvements.collect(&:teacher_hours_cm).sum.round(2)
  end
  
  def planned_teacher_hours_td
    involvements.collect(&:teacher_hours_td).sum.round(2)
  end

  def planned_teacher_hours_tp
    involvements.collect(&:teacher_hours_tp).sum.round(2)
  end

  def planned_teacher_hours
    planned_teacher_hours_cm + planned_teacher_hours_td + planned_teacher_hours_tp
  end

  # Costs

  def planned_teacher_hours_costs
    involvements.collect(&:teacher_hours_costs).sum.round(2)
  end

  def planned_teacher_hours_cm_costs
    involvements.collect(&:teacher_hours_cm_costs).sum.round(2)
  end 

  def planned_teacher_hours_td_costs
    involvements.collect(&:teacher_hours_td_costs).sum.round(2)
  end

  def planned_teacher_hours_tp_costs
    involvements.collect(&:teacher_hours_tp_costs).sum.round(2)
  end

  def cost_per_student_hour
    if expected_student_hours == 0
      0
    else
      (planned_teacher_hours_costs / expected_student_hours * 1.0).round(2)
    end
  end

  def to_s
    "#{code}"
  end

  def full_name
    "#{code} - #{label}"
  end

end
