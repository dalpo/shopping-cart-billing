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

  describe '#discount_price_difference' do
    context 'when discounted' do
      let(:cart)  { create :cart }
      let(:item) { create :item_with_discount, price: 100.0 }

      context 'its item_category discount' do
        subject { item.item_category.discount }

        # Check the factory discount
        it { is_expected.to eq 10.0 }
      end

      context 'with one product' do
        before(:each) { cart.add item }
        subject { cart.cart_items.first.discount_price_difference }

        it { is_expected.to eq 10.0 }
      end

      context 'with more products' do
        before(:each) { cart.add item, 3 }
        subject { cart.cart_items.first.discount_price_difference }

        it { is_expected.to eq 30.0 }
      end
    end

    context 'without any discount' do
      let(:cart)  { create :cart }
      let(:item) { create :item_without_discount, price: 100.0 }

      context 'its item_category discount' do
        subject { item.item_category.discount }

        # Check the factory discount
        it { is_expected.to eq 0.0 }
      end

      context 'with one product' do
        before(:each) { cart.add item }
        subject { cart.cart_items.first.discount_price_difference }

        it { is_expected.to eq 0.0 }
      end

      context 'with more products' do
        before(:each) { cart.add item, 3 }
        subject { cart.cart_items.first.discount_price_difference }

        it { is_expected.to eq 0.0 }
      end
    end
  end
end
