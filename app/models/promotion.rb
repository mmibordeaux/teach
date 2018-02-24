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

  def sync_events
    events.destroy_all
    calendar_events.each do |event|
      date = event.dtstart
      duration = (event.dtend - date) / 60 / 60
      teaching_module = nil
      hashtags = event.description.scan(/#(\w+)/).flatten
      kind = Event.kinds[:cm] # default
      hashtags.each do |hashtag|
        case hashtag.downcase
        when 'cm'
          kind = Event.kinds[:cm]
        when 'td'
          kind = Event.kinds[:td]
        when 'tp'
          kind = Event.kinds[:tp]
        else
          teaching_module = TeachingModule.where(code: hashtag.upcase).first 
        end
      end
      Event.create promotion: self,
        duration: duration,
        date: date,
        kind: kind,
        teaching_module: teaching_module
    end
    events.reload
  end

  def to_s
    "MMI #{year}"
  end
end
