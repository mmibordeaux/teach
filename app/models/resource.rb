class Resource < ApplicationRecord
  belongs_to :semester

  def to_s
    "#{code} - #{label}"
  end
end
