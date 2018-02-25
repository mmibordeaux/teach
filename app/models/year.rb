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

  def self.create_necessary
    year = Date.today.year
    where(year: year).first_or_create
    where(year: year+1).first_or_create
  end

  def self.current
    create_necessary
    year = Date.today.year
    year += 1 if Date.today.month >= 8
    where(year: year).first
  end

  def from
    Date.new year-1, 9
  end

  def to
    from + 1.year - 1.day
  end

  def first_year_promotion
    Promotion.where(year: year+1).first
  end

  def second_year_promotion
    Promotion.where(year: year).first
  end

  def promotions
    [first_year_promotion, second_year_promotion]
  end

  def involvements
    first_year_promotion_id = first_year_promotion.nil? ? 0 : first_year_promotion.id
    first_year_module_ids = TeachingModule.where(semester_id: [1, 2]).pluck(:id)
    second_year_promotion_id = second_year_promotion.nil? ? 0 : second_year_promotion.id
    second_year_module_ids = TeachingModule.where(semester_id: [3, 4]).pluck(:id)
    Involvement
      .where('(promotion_id = ? AND teaching_module_id IN (?)) 
        OR (promotion_id = ? AND teaching_module_id IN (?))', 
        first_year_promotion_id, first_year_module_ids,
        second_year_promotion_id, second_year_module_ids)
  end

  def events
    Event.where('date >= ? AND date < ?', from, to)
  end

  def users
    involvements.collect(&:user).uniq.sort_by { |user| user.last_name }
  end

  def planned_teacher_hours_for(user)
    involvements_for(user).sum(:teacher_hours)
  end

  def scheduled_teacher_hours_for(user)
    events_for(user).sum(:duration)
  end

  def planned_teaching_modules_for(user)
    involvements_for(user).collect(&:teaching_module).uniq.sort_by { |tm| tm.code }
  end

  def scheduled_teaching_modules_for(user)
    events_for(user).collect(&:teaching_module).uniq.sort_by { |tm| tm.code }
  end

  def planned_hours_for_teaching_module_and_user(teaching_module, user, kind = :teacher_hours)
    involvements_for(user).where(teaching_module: teaching_module).sum(kind)
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

  def to_s
    "#{year-1} - #{year}"
  end

  protected

  def involvements_for(user)
    user.involvements.where(promotion: promotions)
  end

  def events_for(user)
    user.events.where('date >= ? AND date < ?', from, to)
  end
end
