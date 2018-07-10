# == Schema Information
#
# Table name: events
#
#  id                 :integer          not null, primary key
#  date               :date
#  duration           :float
#  teaching_module_id :integer
#  promotion_id       :integer
#  kind               :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  student_hours      :float
#  teacher_hours      :float
#

class Event < ActiveRecord::Base
  belongs_to :teaching_module
  belongs_to :promotion
  has_and_belongs_to_many :users
  
  scope :in_semester, -> (semester) { where(teaching_module: semester.teaching_modules) }

  enum kind: [:cm, :td, :tp]

  before_save :compute_student_hours

  def self.sync(promotion)
    return if promotion.calendar_events.nil?
    promotion.events.delete_all
    promotion.calendar_events.each do |calendar_event|
      create_with calendar_event, promotion
    end
  end

  def self.create_with(calendar_event, promotion)
    date = calendar_event.dtstart
    duration = (calendar_event.dtend - date) / 60 / 60
    teaching_module = nil
    hashtags = calendar_event.description.scan(/#(\w+)/).flatten
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
        teaching_module = TeachingModule.with_code(hashtag).first
      end
    end
    event = Event.create  promotion: promotion,
                          duration: duration,
                          date: date,
                          kind: kind,
                          teaching_module: teaching_module
    calendar_event.attendee.each do |attendee| 
      email = attendee.to_s.remove 'mailto:'
      user = User.where(email: email).first
      event.users << user unless user.nil?
    end
    # Compute hours now that users are set
    event.save
    event
  end

  protected

  def compute_student_hours
    users_count = users.any? ? users.count : 1
    self.teacher_hours = self.duration * users_count
    groups = 1.0
    groups = Involvement::GROUPS_TD if td?
    groups = Involvement::GROUPS_TP if tp?
    self.student_hours = self.teacher_hours / groups
  end
end
