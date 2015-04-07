# == Schema Information
#
# Table name: involvements
#
#  id                 :integer          not null, primary key
#  teaching_module_id :integer
#  user_id            :integer
#  hours              :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  description        :text
#

require 'test_helper'

class InvolvementTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
