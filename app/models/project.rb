# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  label       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#  position    :integer
#  user_id     :integer
#  year_id     :integer
#

class Project < ActiveRecord::Base

  has_many :involvements
  has_and_belongs_to_many :fields
  has_and_belongs_to_many :semesters
  has_and_belongs_to_many :users
  has_and_belongs_to_many :objectives
  belongs_to :user
  belongs_to :year
  
  # TODO validator, position must be 1-52
  accepts_nested_attributes_for :fields, allow_destroy: true
  accepts_nested_attributes_for :semesters, allow_destroy: true

  scope :in_semester, -> (semester) { joins(:semesters).where(semesters: { id: semester } ) }

  default_scope { order('position') }

  def start_date
    return if year.nil? || position.nil? || position < 1 || position > 52
    real_year = year.year
    real_year += 1 if position < 30 # weeks before summer belong to next year
    Date.commercial(real_year, position, 1)
  end

  # Modules though fields, filtered by semesters
  def teaching_modules
    list = []
    fields.each do |field|
      field.teaching_modules.each do |teaching_module|
        list << teaching_module if semesters.include? teaching_module.semester
      end
    end
    list.uniq!
    list
  end

  def student_hours
    sum_involvements :student_hours
  end

  def student_hours_cm
    sum_involvements :student_hours_cm
  end

  def student_hours_td
    sum_involvements :student_hours_td
  end

  def student_hours_tp
    sum_involvements :student_hours_tp
  end

  def teacher_hours
    sum_involvements :teacher_hours
  end

  def to_event
    {
      start_date: {
        month: start_date&.month,
        day: start_date&.day,
        year: start_date&.year
      },
      text: {
        headline: label,
        text: ActionController::Base.helpers.simple_format(description)
      }
    } 
  end

  def to_s
    "#{label}"
  end

  protected

  def sum_involvements(key)
    involvements.collect(&key).sum.round
  end
end
