# == Schema Information
#
# Table name: promotions
#
#  id           :integer          not null, primary key
#  year         :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  calendar_url :string
#

require 'test_helper'

class PromotionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
