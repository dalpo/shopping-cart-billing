class Cart < ActiveRecord::Base
  include AASM

  has_many :cart_items, dependent: :destroy, inverse_of: :cart
  has_many :items, through: :cart_items

  aasm column: :status do
    state :drafted, initial: true
    state :billed

    event :checkout do
      transitions from: :drafted, to: :billed, on_transition: :save_billing!
    end
  end

  def name
    self.new_record?? "New cart" : "Cart ##{self.id}"
  end

  def save_billing!
    self.billed_at = Time.now
  end

  def add(item, size = 1)
    self.cart_items.where(item_id: item.id).first_or_initialize do |ci|
      ci.size += size
      ci.save!
    end
  end

  def volume_discount?
    fail 'do something...'
  end
end
