json.array!(@promotions) do |promotion|
  json.extract! promotion, :id, :year
  json.url api_promotion_url(promotion.year)
end
