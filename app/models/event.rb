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
#  project_id         :integer
#

class Event < ActiveRecord::Base
  belongs_to :teaching_module, optional: true
  belongs_to :resource, optional: true
  belongs_to :project, optional: true
  belongs_to :promotion
  belongs_to :user

  scope :in_semester, -> (semester) {
    where(teaching_module: semester.teaching_modules)
    .or(where(resource: semester.resources))
  }
  scope :tenured, -> {
    joins(:user).where(users: { tenured: true })
  }
  scope :non_tenured, -> {
    joins(:user).where(users: { tenured: false })
  }
  scope :ordered, -> { order(:date) }

  enum kind: [:cm, :td, :tp]

  before_save :compute_student_hours

  def self.create_with(calendar_event, promotion)
    date = calendar_event.dtstart
    date_end = calendar_event.dtend
    if date.class == Icalendar::Values::Date
      # All day event, used for holidays
      duration = 0
      return
    else
      duration = (date_end - date) / 60 / 60
    end
    teaching_module = nil
    resource = nil
    description = calendar_event.description
    description = description.gsub('# ', '#')
    hashtags = description.scan(/#(\w+)/).flatten
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
        resource = Resource.with_code(hashtag).first
      end
    end
    project = Project.at_date_for_promotion(date, promotion)
    users = []
    calendar_event.attendee.each do |attendee|
      email = attendee.to_s.remove 'mailto:'
      user = User.with_email(email).first
      users << user unless user.nil?
    end
    if users.none? && (teaching_module || resource)
      # C'est un enseignement, mais on n'a pas encore défini l'enseignant.
      # on met l'utilisateur temporaire, afin d'identifier les heures à attribuer
      users << User.temporary
    else
      # Sinon, on ne fait rien, c'est à dire que :
      # - soit on n'a pas de users du tout, et aucun event ne sera créé (ex: temps en autonomie, début des stages...)
      # - soit on a un user sans ressource, et on compte ses heures quand même (resource optionnelle)
    end
    users.each do |user|
      event = Event.create  promotion: promotion,
                            duration: duration,
                            date: date,
                            kind: kind,
                            project: project,
                            teaching_module: teaching_module,
                            resource: resource,
                            label: calendar_event.summary,
                            description: calendar_event.description,
                            user: user
      # byebug if 'Intelligence économique'.in? calendar_event.summary
      # puts "Created event #{calendar_event.summary} with #{user}"
    end
  rescue => e
    # byebug
  end

  def from
    @from ||= date.in_time_zone('Paris')
  end

  def to
    @to ||= @from + duration.hours
  end

  protected

  def groups
    unless @groups
      @groups = 1.0
      @groups = Involvement::GROUPS_TD if td?
      @groups = Involvement::GROUPS_TP if tp?
    end
    @groups
  end

  def compute_student_hours
    self.teacher_hours = self.duration
    self.student_hours = self.duration / groups
  end
end
