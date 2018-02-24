class AddPromotionToInvolvements < ActiveRecord::Migration
  def change
    add_reference :involvements, :promotion, index: true, foreign_key: true
  end
end
