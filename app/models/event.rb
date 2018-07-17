# == Schema Information
#
# Table name: events
#
#  id                 :integer          not null, primary key
#  date               :datetime
#  duration           :float
#  teaching_module_id :integer
#  promotion_id       :integer
#  kind               :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  student_hours      :float
#  teacher_hours      :float
#  label              :string
#  description        :text
#

class Event < ActiveRecord::Base
  belongs_to :teaching_module
  belongs_to :promotion
  has_and_belongs_to_many :users
  
  scope :in_semester, -> (semester) { where(teaching_module: semester.teaching_modules) }
  scope :ordered, -> { order(:date) }

  enum kind: [:cm, :td, :tp]

  before_save :compute_student_hours

  def self.create_with(calendar_event, promotion)
    date = calendar_event.dtstart
    date_end = calendar_event.dtend
    duration = (date_end - date) / 60 / 60
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
                          teaching_module: teaching_module,
                          label: calendar_event.summary,
                          description: calendar_event.description
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
