# == Schema Information
#
# Table name: years
#
#  id         :integer          not null, primary key
#  year       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Year < ActiveRecord::Base

  def self.create_necessary
    year = Date.today.year
    where(year: year).first_or_create
    where(year: year+1).first_or_create
  end

  def self.current
    create_necessary
    year = Date.today.year
    year += 1 if Date.today.month >= 8
    where(year: year).first
  end

  def from
    Date.new year-1, 9
  end

  def to
    from + 1.year - 1.day
  end

  def first_year_promotion
    Promotion.where(year: year+1).first
  end

  def second_year_promotion
    Promotion.where(year: year).first
  end

  def promotions
    [first_year_promotion, second_year_promotion]
  end

  def involvements
    Involvement.where(promotion: promotions)
  end

  def events
    Event.where('date >= ? AND date < ?', from, to)
  end

  def to_s
    "#{year-1} - #{year}"
  end
end
