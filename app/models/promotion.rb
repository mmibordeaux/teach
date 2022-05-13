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

  default_scope { order(year: :desc) }

  def first_year
    y = year >= 2024 ? year - 2 : year - 1
    Year.where(year: y).first_or_create
  end

  def second_year
    y = year >= 2024 ? year - 1 : year
    Year.where(year: y).first_or_create
  end

  def third_year
    return if year < 2024
    Year.where(year: year).first_or_create
  end

  def years
    [first_year, second_year]
  end

  def first_year_projects
    first_year.projects.joins(:semesters).where(semesters: { id: [1, 2] })
  end

  def second_year_projects
    second_year.projects.joins(:semesters).where(semesters: { id: [3, 4] })
  end

  def third_year_projects
    third_year.projects.joins(:semesters).where(semesters: { id: [5, 6] })
  end

  def year_for_teaching_module(teaching_module)
    return first_year if teaching_module.semester_id.in? [1, 2]
    second_year
  end

  def projects
    first_year_projects + second_year_projects
  end

  def projects_in(semester)
    projects_concerned = semester.id.in?([1, 2]) ? first_year_projects : second_year_projects
    projects_concerned.where(semesters: { id: semester } )
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
    cal_file = URI.open calendar_url
    events = Icalendar::Parser.new(cal_file).parse.first.events
    events.sort_by { |event| event.dtstart }
  rescue
  end

  def sync_events
    return if calendar_events.nil?
    events.destroy_all
    calendar_events.each do |calendar_event|
      Event.create_with calendar_event, self
    end
  end
  handle_asynchronously :sync_events

  def to_s
    "Promotion #{year}"
  end
end
