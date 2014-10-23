require 'rails_helper'

RSpec.describe Item, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :price }
  end

  context 'associations' do
    it { is_expected.to belong_to :item_category }
    it { is_expected.to have_many :cart_items }
  end

  describe '#category_discount' do
    context 'when has not an item_category' do
      let(:item) { create :item }
      subject(:category_discount) { item.category_discount }

      it { is_expected.to eq 0.0 }
    end

    context 'when has an item_category without a discount' do
      let(:item) { create :item }
      subject(:category_discount) { item.category_discount }

      it { is_expected.to eq 0.0 }
    end

    context 'when has an item_category with a discount' do
      let(:item_category) { create :item_category, discount: 5.0 }
      let(:item) { create :item, item_category: item_category }
      subject(:category_discount) { item.category_discount }

      it { is_expected.to eq 5.0 }
    end
  end

  describe '#discount_price_difference' do
    context 'without a discount' do
      let(:item) { create :item_without_discount }
      subject(:discount_price_difference) { item.discount_price_difference }

      it { is_expected.to eq 0.0 }
    end

    context 'with a discount' do
      let(:item_category) { create :item_category, discount: 5.0 }
      let(:item) { create :item, item_category: item_category, price: 200.0 }
      subject(:discount_price_difference) { item.discount_price_difference }

      it { is_expected.to eq 10.0 }
    end
  end

  describe '#final_price' do
    context 'without a discount' do
      let(:item) { create :item_without_discount, price: 123.0 }
      subject(:final_price) { item.final_price }

      it { is_expected.to eq 123.0 }
      it { is_expected.to eq item.price }
    end

    context 'with a discount' do
      let(:item_category) { create :item_category, discount: 5.0 }
      let(:item) { create :item, item_category: item_category, price: 200.0 }
      subject(:final_price) { item.final_price }

      it { is_expected.to eq 190.0 }
      it { is_expected.to_not eq item.price }
    end
  end
end
