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
#

class User < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :validatable, :rememberable, :trackable

  default_scope { order('last_name, first_name') }

  has_many :teaching_modules
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :fields
  has_many :involvements, dependent: :destroy
  has_many :teaching_modules_involved, through: :involvements
  has_many :projects_managed, foreign_key: :user_id, class_name: Project, dependent: :nullify

  accepts_nested_attributes_for :teaching_modules
  accepts_nested_attributes_for :projects
  accepts_nested_attributes_for :fields

  STUDENTS_HOURS = 1800
  BUDGET = 100000
  PER_HOUR_PRICE = 60
  EXTRA_HOURS = BUDGET / PER_HOUR_PRICE
  
  def no_hours?
    (teacher_hours.nil? or teacher_hours.zero?) and (hours.nil? or hours.zero?)
  end

  def teacher_hours
    involvements.collect(&:teacher_hours).sum
  end

  def student_hours
    involvements.collect(&:student_hours).sum
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
  
  def to_s
    "#{first_name} #{last_name}"
  end

end
