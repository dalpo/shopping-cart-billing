class Item < ActiveRecord::Base
  belongs_to :item_category, inverse_of: :items

  has_many :cart_items, inverse_of: :item
  has_many :items, through: :cart_items

  validates :name,  presence: true
  validates :price, presence: true

  def category_discount
    @category_discount ||= self.item_category.try(:discount) || 0.0
  end
  alias_method :discount, :category_discount

  def discount_price_difference
    @discount_price_difference ||= self.price * self.discount / 100
  end

  def discounted_price
    @discounted_price ||= self.price - self.discount_price_difference
  end
end
