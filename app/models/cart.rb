class Cart < ActiveRecord::Base
  include AASM

  VOLUME_DISCOUNT = 5.0 # 5%
  MIN_PRICE_VOLUME_DISCOUNT = 40.0

  has_many :cart_items, dependent: :destroy, inverse_of: :cart
  has_many :items, through: :cart_items

  # State machine
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

  def add(item, size = 1)
    ci = self.cart_items.where(item_id: item.id).first_or_initialize
    ci.size += size
    ci.save!

    return self
  end

  def gross_total
    self.cart_items.map(&:final_price).sum
  end

  def apply_volume_discount?
    self.gross_total > MIN_PRICE_VOLUME_DISCOUNT
  end

  def volume_discount_amount
    self.gross_total * ( VOLUME_DISCOUNT / 100.0 )
  end

  def raw_final_price
    if self.apply_volume_discount?
      (self.gross_total - self.volume_discount_amount)
    else
      self.gross_total
    end
  end

  def rounded_final_price
    (self.raw_final_price * 20 + 0.5).to_i / 20.0
  end

  # Final total rounded off to nearest 5 cents
  def final_price
    if self.billed?
      self[:final_price]
    else
      self.rounded_final_price
    end
  end

  def item_category_total_discount
    self.cart_items.map(&:discount_price_difference).sum
  end

  def total_discount
    if self.apply_volume_discount?
      self.item_category_total_discount + self.volume_discount_amount
    else
      self.item_category_total_discount
    end
  end

  private

    def set_final_billing
      self.final_price = self.final_price
      self.billed_at   = Time.now
    end
end
