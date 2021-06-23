# == Schema Information
#
# Table name: years
#
#  id         :integer          not null, primary key
#  year       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Year < ActiveRecord::Base

  has_many :projects
  has_many :objectives, through: :projects

  def self.create_necessary
    year = Date.today.year
    where(year: year-1).first_or_create
    where(year: year).first_or_create
    where(year: year+1).first_or_create
    where(year: year+2).first_or_create
    where(year: year+3).first_or_create
  end

  def self.current
    create_necessary
    year = Date.today.year
    year += 1 if Date.today.month >= 7
    where(year: year).first
  end

  def from
    @from ||= Date.new year-1, 9
  end

  def to
    @to ||= from + 1.year - 1.day
  end

  def first_year_promotion
    y = year < 2022 ? year+1 : year+2
    Promotion.where(year: y).first
  end

  def second_year_promotion
    y = year < 2023 ? year : year+1
    Promotion.where(year: y).first
  end

  def third_year_promotion
    return if year < 2024
    Promotion.where(year: year).first
  end

  def promotions
    [first_year_promotion, second_year_promotion]
  end

  def involvements
    if @involvements.nil?
      first_year_promotion_id = first_year_promotion.nil? ? nil : first_year_promotion.id
      first_year_module_ids = TeachingModule.where(semester_id: [1, 2]).pluck(:id)
      second_year_promotion_id = second_year_promotion.nil? ? nil : second_year_promotion.id
      second_year_module_ids = TeachingModule.where(semester_id: [3, 4]).pluck(:id)
      @involvements = Involvement
                        .where( '(promotion_id = ? AND teaching_module_id IN (?)) OR (promotion_id = ? AND teaching_module_id IN (?))',
                                first_year_promotion_id, first_year_module_ids,
                                second_year_promotion_id, second_year_module_ids)
    end
    @involvements
  end

  def projects_with_user_involved(user)
    involvements_for_user(user).collect(&:project).uniq.compact.to_ary.sort_by(&:week_number)
  end

  def users
    @users ||= (users_with_involvements + users_with_events).uniq.sort_by { |user| user&.last_name }
  end

  # Planned (involvements)

  def involvements_for_user(user)
    involvements.where(user: user)
  end

  def involvements_for_teaching_module(teaching_module)
    involvements.where(teaching_module: teaching_module)
  end

  def planned_student_hours
    involvements.collect(&:student_hours).sum.round(2)
  end

  def planned_teacher_hours
    involvements.collect(&:teacher_hours).sum.round(2)
  end

  def planned_hours_for(user, kind = :teacher_hours)
    involvements_for_user(user).sum(kind)
  end

  def planned_teaching_modules_for(user)
    involvements_for_user(user).collect(&:teaching_module).uniq.sort_by { |tm| tm.code }
  end

  def planned_delta_for(user)
    return 0 if user.hours.nil?
    planned_hours_for(user) - user.hours
  end

  def planned_hours_for_teaching_module(teaching_module, kind = :teacher_hours)
    involvements_for_teaching_module(teaching_module).sum(kind)
  end

  def planned_hours_for_teaching_module_and_user(teaching_module, user, kind = :teacher_hours)
    involvements_for_user(user).where(teaching_module: teaching_module).sum(kind)
  end

  # Scheduled (events)

  def scheduled_student_hours
    @scheduled_student_hours ||= events.sum(:student_hours)
  end

  def scheduled_teacher_hours
    @scheduled_teacher_hours ||= events.sum(:teacher_hours)
  end

  def scheduled_student_hours_by_tenured_teachers
    @scheduled_student_hours_by_tenured_teachers ||= events.joins(:user).where('users.tenured = true').sum(:student_hours)
  end

  def scheduled_student_hours_by_non_tenured_teachers
    @scheduled_student_hours_by_non_tenured_teachers ||= events.joins(:user).where('users.tenured = false').sum(:student_hours)
  end

  def scheduled_student_hours_non_tenured_ratio
    return 0 if scheduled_student_hours.zero?
    100.0 * scheduled_student_hours_by_non_tenured_teachers / scheduled_student_hours
  end

  def scheduled_hours_for(user, kind = nil)
    events_for(user, kind).sum(:duration)
  end

  def scheduled_hours_ponderated_for(user)
    cm = events_for(user).cm.sum(:duration) * Involvement::COST_RATIO_CM
    td = events_for(user).td.sum(:duration) * Involvement::COST_RATIO_TD
    tp = events_for(user).tp.sum(:duration) * Involvement::COST_RATIO_TP
    cm + td + tp
  end

  def scheduled_teacher_hours_for(user, kind = nil)
    events_for(user, kind).sum(:teacher_hours)
  end

  def scheduled_student_hours_for(user, kind = nil)
    events_for(user, kind).sum(:student_hours)
  end

  def events
    @events ||= Event.where('date >= ? AND date < ?', from, to)
  end

  def events_for(user, kind = nil)
    events = user.events.where('date >= ? AND date < ?', from, to)
    events = events.send(kind) if kind
    events
  end

  def scheduled_teaching_modules_for(user)
    teaching_modules = events_for(user).collect(&:teaching_module).uniq.compact
    teaching_modules.sort_by { |tm| tm.code }
  end

  def scheduled_hours_for_teaching_module(teaching_module, kind_of_hours = nil)
    e = events.where(teaching_module: teaching_module)
    e = e.send(kind_of_hours) if kind_of_hours
    e.sum(:student_hours)
  end

  def scheduled_hours_for_teaching_module_and_user(teaching_module, user, kind = :teacher_hours)
    events = events_for(user).where(teaching_module: teaching_module)
    case kind
    when :hours_cm
      events = events.cm
    when :hours_td
      events = events.td
    when :hours_tp
      events = events.tp
    end
    events.sum :duration
  end

  def scheduled_delta_for(user)
    return 0 if user.hours.nil?
    scheduled_hours_for(user) - user.hours
  end

  def to_s
    "#{year-1} - #{year}"
  end

  protected

  def users_with_involvements
    involvements.where.not(user: nil).collect(&:user)
  end

  def users_with_events
    events.where.not(user: nil).collect(&:user)
  end
end
