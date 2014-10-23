require 'rails_helper'

RSpec.describe CartItem, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :cart }
    it { is_expected.to belong_to :item }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :cart_id }
    it { is_expected.to validate_presence_of :item_id }
    it do
      is_expected.to validate_numericality_of(:size)
        .is_greater_than(0)
        .only_integer
    end
  end
end
