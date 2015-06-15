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
    involvements.collect(&:teacher_hours).sum
  end

  def student_hours
    involvements.collect(&:student_hours).sum
  end

  def student_hours_delta
    result = 0
    unless hours == 0
      result = student_hours * 1.0 / hours * 1.0
    end
    (result - 1) * 100
  end

  def student_hours_delta_warning
    student_hours_delta.abs > 30
  end

  def to_s
    "#{code}"
  end

  def full_name
    "#{code} - #{label}"
  end

end
