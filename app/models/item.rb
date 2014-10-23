class Item < ActiveRecord::Base
  belongs_to :item_category, inverse_of: :items

  has_many  :cart_items, inverse_of: :item
  has_many  :items,   through: :cart_items

  validates :name,  presence: true
  validates :price, presence: true

  def category_discount
    self.item_category.try(:discount) || 0.0
  end

  def discount_price_difference
    if self.category_discount > 0.0
      (self.price * self.category_discount / 100.0).round(2)
    else
      0.0
    end
  end

  def final_price
    (self.price - self.discount_price_difference).round(2)
  end
end
