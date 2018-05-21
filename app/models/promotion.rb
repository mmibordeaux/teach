# == Schema Information
#
# Table name: promotions
#
#  id           :integer          not null, primary key
#  year         :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  calendar_url :string
#

class Promotion < ActiveRecord::Base
  has_many :involvements
  has_many :events

  default_scope { order(:year) }

  def first_year
    Year.where(year: year-2).first
  end

  def second_year
    Year.where(year: year-1).first
  end

  def years
    [first_year, second_year]
  end

  def projects(semester)
    semester.projects.where(year: years)
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

  def calendar_events
    return [] if calendar_url.blank?
    require 'open-uri'
    cal_file = open calendar_url
    Icalendar::Parser.new(cal_file).parse.first.events
  end

  def to_s
    "MMI #{year}"
  end
end
