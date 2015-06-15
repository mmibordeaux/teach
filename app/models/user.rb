# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  first_name :string
#  last_name  :string
#  hours      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenured    :boolean
#

class User < ActiveRecord::Base

  default_scope { order('last_name, first_name') }

  has_many :teaching_modules
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :fields
  has_many :involvements
  has_many :teaching_modules_involved, through: :involvements
  has_many :projects_managed, foreign_key: :user_id, class: Project

  accepts_nested_attributes_for :teaching_modules
  accepts_nested_attributes_for :projects
  accepts_nested_attributes_for :fields

  STUDENTS_HOURS = 1600
  BUDGET = 100000
  PER_HOUR_PRICE = 60
  EXTRA_HOURS = BUDGET / PER_HOUR_PRICE
  
  def teacher_hours
    involvements.collect(&:teacher_hours).sum
  end

  def student_hours
    involvements.collect(&:student_hours).sum
  end
  
  def hours_delta
    unless teacher_hours.nil? or hours.nil?
      return teacher_hours - hours
    end
    return 0
  end

  def hours_filled?
    hours_delta >= 0
  end

  def to_s
    "#{first_name} #{last_name}"
  end

end
