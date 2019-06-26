# == Schema Information
#
# Table name: involvements
#
#  id                 :integer          not null, primary key
#  teaching_module_id :integer
#  user_id            :integer
#  hours_cm           :integer          default(0)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  description        :text
#  hours_td           :integer          default(0)
#  hours_tp           :integer          default(0)
#  multiplier_td      :integer          default(2)
#  multiplier_tp      :integer          default(3)
#  groups_tp          :integer          default(3)
#  project_id         :integer
#  promotion_id       :integer
#  teacher_hours_cm   :float            default(0.0), not null
#  teacher_hours_td   :float            default(0.0), not null
#  teacher_hours_tp   :float            default(0.0), not null
#  teacher_hours      :float            default(0.0), not null
#  student_hours_cm   :float            default(0.0), not null
#  student_hours_td   :float            default(0.0), not null
#  student_hours_tp   :float            default(0.0), not null
#  student_hours      :float            default(0.0), not null
#

class Involvement < ActiveRecord::Base
  belongs_to :teaching_module
  belongs_to :user
  belongs_to :project
  belongs_to :promotion

  scope :in_semester, -> (semester) { where(teaching_module: semester.teaching_modules) }

  delegate :expected_student_hours, to: :teaching_module

  GROUPS_TD = 2.0
  GROUPS_TP = 3.0

  before_validation :check_hours
  before_save :denormalize

  def self.student_hours
    all.collect(&:student_hours).sum.round(2)
  end

  def self.teacher_hours
    all.collect(&:teacher_hours).sum.round(2)
  end

  def self.tenured_teacher_hours
    joins(:user).where('users.tenured = true').collect(&:teacher_hours).sum.round(2)
  end

  def self.untenured_teacher_hours
    teacher_hours - tenured_teacher_hours
  end

  # Costs

  COST_RATIO_CM = 1.5
  COST_RATIO_TD = 1
  # COST_RATIO_TP = 0.66
  COST_RATIO_TP = 1

  COST_HOUR_PRIVATE = 58.31
  COST_HOUR_PUBLIC = 42.96

  def teacher_hours_cm_costs
    teacher_hours_cm * COST_RATIO_CM * cost_hour
  end

  def teacher_hours_td_costs
    teacher_hours_td * COST_RATIO_TD * cost_hour
  end

  def teacher_hours_tp_costs
    teacher_hours_tp * COST_RATIO_TP * cost_hour
  end

  def teacher_hours_costs
    teacher_hours_cm_costs + teacher_hours_td_costs + teacher_hours_tp_costs
  end

  def cost_hour
    return 0 if user.nil?
    user.public ? COST_HOUR_PUBLIC : COST_HOUR_PRIVATE
  end

  def to_s
    "#{user} - #{teaching_module.code} (CM #{hours_cm}h, TD #{hours_td}, TP #{hours_tp})"
  end

  protected

  def check_hours
    self.hours_cm ||= 0
    self.hours_td ||= 0
    self.hours_tp ||= 0
  end

  def denormalize
    # Teacher hours
    self.teacher_hours_cm = hours_cm
    self.teacher_hours_td = hours_td * multiplier_td
    self.teacher_hours_tp = hours_tp * multiplier_tp
    self.teacher_hours = self.teacher_hours_cm + self.teacher_hours_td + self.teacher_hours_tp

    # Student hours
    self.student_hours_cm = hours_cm
    self.student_hours_td = 1.0 * multiplier_td / GROUPS_TD * hours_td
    divider = groups_tp.nil? ? GROUPS_TP : groups_tp
    self.student_hours_tp = ( 1.0 * multiplier_tp / divider * hours_tp).round(2)
    self.student_hours = self.student_hours_cm + self.student_hours_td + self.student_hours_tp
  end
end
