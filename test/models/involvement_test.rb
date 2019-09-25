# == Schema Information
#
# Table name: involvements
#
#  id                 :integer          not null, primary key
#  teaching_module_id :integer
#  user_id            :integer
#  hours_cm           :float            default(0.0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  description        :text
#  hours_td           :float            default(0.0), not null
#  hours_tp           :float            default(0.0), not null
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

require 'test_helper'

class InvolvementTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
