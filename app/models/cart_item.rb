class CartItem < ActiveRecord::Base
  belongs_to :cart, inverse_of: :cart_items
  belongs_to :item, inverse_of: :cart_items

  delegate :name, :discount, :price, :final_price, :discount_price_difference, to: :item, prefix: 'item'

  validates :cart_id, presence: true
  validates :item_id, presence: true
  validates :size, numericality: { only_integer: true, greater_than: 0 }

  def final_price
    (self.item_final_price * self.size).round(2)
  end

  def discount_price_difference
    (self.item_discount_price_difference * self.size).round(2)
  end
end
