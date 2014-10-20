class CartItem < ActiveRecord::Base
  belongs_to :cart, inverse_of: :cart_items
  belongs_to :item, inverse_of: :cart_items

  delegate :name, :discount, :price, :discounted_price, to: :item, prefix: 'item'

  validates :cart_id, presence: true
  validates :item_id, presence: true
  validates :size, numericality: { only_integer: true, greater_than: 0 }
end
