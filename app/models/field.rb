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
#  color      :string
#

class Field < ActiveRecord::Base

  belongs_to :parent, class_name: Field
  has_many :children, class_name: Field, foreign_key: :parent_id
  has_many :fields_teaching_modules
  has_many :teaching_modules, through: :fields_teaching_modules
  has_many :fields_projects
  has_many :projects, through: :fields_projects
  
  accepts_nested_attributes_for :fields_teaching_modules, allow_destroy: true
  accepts_nested_attributes_for :fields_projects, allow_destroy: true
  accepts_nested_attributes_for :projects

  scope :root, -> { where(parent_id: nil) }
  scope :not_root, -> { where.not(parent_id: nil) }
  scope :sorted, -> { order(:position) }
  
  def teaching_modules_including_children
    list = teaching_modules
    if children.any?
      children.each do |child|
        list += child.teaching_modules
      end
    end
    list.uniq!
    list
  end

  def keywords_including_children
    list = []
    teaching_modules_including_children.each do |tm|
      list += tm.keywords
    end
    list.uniq!
    list
  end

  def hours
    hours = children.map{|c|c.hours}.sum
    hours += teaching_modules.map{|tm|tm.hours}.sum
    hours
  end

  def projects
    list = super
    if children.any?
      children.each do |child|
        list += child.projects
      end
    end
    list.uniq!
    list
  end

  def to_s
    "#{label}"
  end

end
