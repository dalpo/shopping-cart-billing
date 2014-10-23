class ItemCategory < ActiveRecord::Base
  has_many :items, inverse_of: :item_category

  validates :name, presence: true

  after_initialize :set_default_values

  def set_default_values
    self.discount ||= 0.0
  end
end
