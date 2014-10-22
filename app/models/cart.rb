class Cart < ActiveRecord::Base
  include AASM

  VOLUME_DISCOUNT = 5 # %
  MIN_PRICE_VOLUME_DISCOUNT = 40.0

  has_many :cart_items, dependent: :destroy, inverse_of: :cart
  has_many :items, through: :cart_items

  aasm column: :status do
    state :drafted, initial: true
    state :billed

    event :checkout do
      transitions from: :drafted, to: :billed, on_transition: :set_final_billing
    end
  end

  validates :cart_items, length: { minimum: 1 }, if: :billed?
  validates_associated :cart_items,              if: :billed?

  def name
    self.new_record?? "New cart" : "Cart ##{self.id}"
  end

  def set_final_billing
    self.billed_at = Time.now
  end

  def add(item, size = 1)
    self.cart_items.where(item_id: item.id).first_or_initialize do |ci|
      ci.size += size
      ci.save!
    end
  end

  def gross_total
    self.cart_items.map(&:item_final_price).sum
  end

  def apply_volume_discount?
    self.gross_total > MIN_PRICE_VOLUME_DISCOUNT
  end

  def discount_price_difference
    self.gross_total * ( VOLUME_DISCOUNT / 100.0 )
  end

  def raw_final_price
    if self.apply_volume_discount?
      (self.gross_total - self.discount_price_difference)
    else
      self.gross_total
    end
  end

  # Final total rounded off to nearest 5 cents
  def final_price
    self.raw_final_price.round(1)
  end
end
