# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  first_name             :string
#  last_name              :string
#  hours                  :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  tenured                :boolean
#  public                 :boolean
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  admin                  :boolean          default(FALSE), not null
#  email_secondary        :string
#

class User < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :rememberable, :trackable

  scope :with_email, -> (email) { where('email LIKE ? OR email_secondary LIKE ?', email, email) }
  default_scope { order('last_name, first_name') }

  has_many :teaching_modules
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :fields
  has_and_belongs_to_many :events, dependent: :destroy
  has_many :involvements, dependent: :destroy
  has_many :teaching_modules_involved, through: :involvements
  has_many :projects_managed, foreign_key: :user_id, class_name: 'Project', dependent: :nullify

  accepts_nested_attributes_for :teaching_modules
  accepts_nested_attributes_for :projects
  accepts_nested_attributes_for :fields

  STUDENTS_HOURS = 1800
  BUDGET = 100000
  PER_HOUR_PRICE = 60
  EXTRA_HOURS = BUDGET / PER_HOUR_PRICE

  # Intervenant à préciser (id: 104)
  def self.temporary
    find(104)
  end

  def no_hours?
    (teacher_hours.nil? or teacher_hours.zero?) and (hours.nil? or hours.zero?)
  end

  def teacher_hours
    involvements.collect(&:teacher_hours).sum
  end

  def teacher_hours_cm
    involvements.collect(&:teacher_hours_cm).sum
  end

  def teacher_hours_td
    involvements.collect(&:teacher_hours_td).sum
  end

  def teacher_hours_tp
    involvements.collect(&:teacher_hours_tp).sum
  end

  def student_hours
    involvements.collect(&:student_hours).sum
  end

  def student_hours_cm
    involvements.collect(&:student_hours_cm).sum
  end

  def student_hours_td
    involvements.collect(&:student_hours_td).sum
  end

  def student_hours_tp
    involvements.collect(&:student_hours_tp).sum
  end

  def hours_delta
    unless teacher_hours.nil? or hours.nil?
      return teacher_hours - hours
    end
    return 0
  end

  def hours_filled?
    hours_delta >= 0
  end

  # Costs

  def teacher_hours_cm_costs
    involvements.collect(&:teacher_hours_cm_costs).sum
  end

  def teacher_hours_td_costs
    involvements.collect(&:teacher_hours_td_costs).sum
  end

  def teacher_hours_tp_costs
    involvements.collect(&:teacher_hours_tp_costs).sum
  end

  def teacher_hours_costs
    involvements.collect(&:teacher_hours_costs).sum
  end

  def cost_for_year(year)
    year_involvements = year.involvements.where(user: self)
    cm = year_involvements.collect(&:teacher_hours_cm).sum
    td = year_involvements.collect(&:teacher_hours_td).sum
    tp = year_involvements.collect(&:teacher_hours_tp).sum
    total_hours = cm * Involvement::COST_RATIO_CM
    total_hours += td * Involvement::COST_RATIO_TD
    total_hours += tp * Involvement::COST_RATIO_TP
    extra_hours = total_hours - hours.to_i
    extra_hours = [0, extra_hours].max
    cost = public ? Involvement::COST_HOUR_PUBLIC
                  : Involvement::COST_HOUR_PRIVATE
    extra_hours * cost
  end

  def to_s
    "#{first_name} #{last_name}"
  end

end
