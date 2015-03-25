# == Schema Information
#
# Table name: fields
#
#  id         :integer          not null, primary key
#  label      :string
#  parent_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  position   :integer
#

class Field < ActiveRecord::Base

  belongs_to :parent, class_name: Field
  has_many :fields_teaching_modules
  has_many :teaching_modules, through: :fields_teaching_modules
  has_many :children, class_name: Field, foreign_key: :parent_id
  
  accepts_nested_attributes_for :fields_teaching_modules, allow_destroy: true
  accepts_nested_attributes_for :teaching_modules
  
  def to_s
    "#{label}"
  end

end
