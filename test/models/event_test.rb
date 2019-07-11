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

require 'test_helper'

class EventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
