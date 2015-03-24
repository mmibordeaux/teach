# == Schema Information
#
# Table name: competencies
#
#  id                 :integer          not null, primary key
#  label              :string
#  teaching_module_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class CompetencyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
