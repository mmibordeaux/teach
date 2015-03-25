# == Schema Information
#
# Table name: fields
#
#  id         :integer          not null, primary key
#  label      :string
#  parent_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Field < ActiveRecord::Base

  def to_s
    "#{label}"
  end

end
