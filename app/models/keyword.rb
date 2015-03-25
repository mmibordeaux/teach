# == Schema Information
#
# Table name: keywords
#
#  id                 :integer          not null, primary key
#  label              :string
#  teaching_module_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Keyword < ActiveRecord::Base

  # Should be a many to many with a joint table, some keywords are used multiple times
  belongs_to :teaching_module

  def to_s
    "#{label}"
  end

end
