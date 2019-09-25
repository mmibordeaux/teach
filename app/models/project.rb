# == Schema Information
#
# Table name: projects
#
#  id                   :integer          not null, primary key
#  label                :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  description          :text
#  position             :integer
#  user_id              :integer
#  year_id              :integer
#  detailed_description :text
#  sublabel             :string
#  from                 :date
#  to                   :date
#

class Project < ActiveRecord::Base

  has_many :involvements
  has_many :events
  has_and_belongs_to_many :fields
  has_and_belongs_to_many :semesters
  has_and_belongs_to_many :users
  has_and_belongs_to_many :objectives
  belongs_to :user
  belongs_to :year

  validates_inclusion_of :position, in: 1..52
  accepts_nested_attributes_for :fields, allow_destroy: true
  accepts_nested_attributes_for :semesters, allow_destroy: true

  scope :in_semester, -> (semester) { joins(:semesters).where(semesters: { id: semester } ) }

  before_save :fix_dates

  default_scope { order('position') }

  def self.at_date_for_promotion(date, promotion)
    where(id: promotion.projects).where('? >= "from" AND ? <= "to"', date.to_date, date.to_date).first
  end

  def start_date
    return if year.nil? || position.nil? || position < 1 || position > 52
    Date.commercial(real_year, position, 1)
  end

  def real_year
    y = year.year
    # weeks before summer belong to next year
    position < 30 ? y : y-1
  end

  def week_number
    "#{real_year}-#{ '%02d' % position}"
  end

  def possible_teaching_modules
    ids = objectives.collect &:teaching_module_id
    TeachingModule.where(semester: semesters, id: ids)
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

  def involvements_for_user(user)
    involvements.where(user: user)
  end

  def planned_hours_for_user(user, kind = :teacher_hours)
    involvements_for_user(user).sum(kind)
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

  def teacher_hours_cm
    sum_involvements :teacher_hours_cm
  end

  def teacher_hours_td
    sum_involvements :teacher_hours_td
  end

  def teacher_hours_tp
    sum_involvements :teacher_hours_tp
  end

  # Scheduled (events)

  def events_for_user(user)
    events.includes(:users).where(users: { id: user.id })
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

  def evaluation
    learn_api_url = "http://learn.mmibordeaux.com/api/projects/#{id}"
    response = Net::HTTP.get_response(URI.parse(learn_api_url))
    JSON.parse response.body
  end

  def sync_involvements_from_events
    involvements.find_each &:reset_hours!
    events.each do |event|
      event.users.each do |user|
        involvement = involvements.where( teaching_module: event.teaching_module,
                                          user: user,
                                          promotion: event.promotion)
                                  .first_or_initialize
        case event.kind
        when 'cm'
          involvement.hours_cm += event.student_hours / event.users.count
        when 'td'
          involvement.hours_td += event.student_hours / event.users.count
        when 'tp'
          involvement.hours_tp += event.student_hours / event.users.count
        end
        involvement.save
      end
    end
  end

  def to_s
    return 'Projet sans titre' if label.blank?
    "#{label}"
  end

  protected

  def fix_dates
    self.from = nil if position_changed?
    if self.from.blank?
      self.from = start_date
      self.to = self.from + 5.days
    end
  end

  def sum_involvements(key)
    involvements.collect(&key).sum.round
  end
end
