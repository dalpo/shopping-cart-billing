require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'associations' do
    it { is_expected.to have_many :cart_items }
  end

  context 'validations' do
    context 'when the status is drafted' do
      subject(:cart) { build :cart }

      it { is_expected.to be_valid }
    end

    context 'when the status is billed' do
      context 'without cart_items' do
        subject(:cart) do
          create(:cart).tap { |c| c.status = 'billed' }
        end

        it { is_expected.to_not be_valid }

        it 'should not validate :cart_items' do
          cart.valid?
          expect(cart.errors.keys).to include(:cart_items)
        end
      end

      context 'with cart_items' do
        subject(:cart) do
          create(:cart_with_items).tap { |c| c.status = 'billed' }
        end

        it { is_expected.to be_valid }
        it { is_expected.to be_persisted }
      end
    end
  end

  describe '#name' do
    context 'New cart' do
      let(:cart) { build :cart }
      subject { cart.name }

      it { is_expected.to eq 'New cart' }
    end

    context 'Existing cart' do
      let(:cart) { create :cart }
      subject { cart.name }

      it { is_expected.to eq "Cart ##{cart.id}" }
    end
  end

  describe '#add' do
    let(:cart)  { create :cart }
    let(:item1) { create :item }
    let(:item2) { create :item }

    context 'when add a single item' do
      before :each do
        cart.add item1
      end

      it 'should count one cart_item' do
        expect(cart.cart_items.count).to eq 1
      end

      it 'should add the product in the cart only for 1 time' do
        expect(cart.cart_items.first.size).to eq 1
      end

      it 'should persist the cart_item' do
        expect(cart.cart_items.first).to be_persisted
      end
    end

    context 'when add more times the same product' do
      before :each do
        cart.add item1
        cart.add item1, 2
        cart.add item1, 3
      end

      it 'should count one cart_item for the first item' do
        expect(cart.cart_items.count).to eq 1
      end

      it 'should add the product in the cart for 6 times' do
        expect(cart.cart_items.first.size).to eq 6
      end

      it 'should persist the cart_item' do
        expect(cart.cart_items.first).to be_persisted
      end
    end

    context 'when add more times different products' do
      before :each do
        cart.add item1
        cart.add item1, 2
        cart.add item2, 4
      end

      let(:cart_item1) { cart.cart_items.where(item_id: item1.id).take }
      let(:cart_item2) { cart.cart_items.where(item_id: item2.id).take }

      it 'should count two cart_items' do
        expect(cart.cart_items.count).to eq 2
      end

      it 'should add the first product in the cart for 3 times' do
        expect(cart_item1.size).to eq 3
      end

      it 'should add the first product in the cart for 4 times' do
        expect(cart_item2.size).to eq 4
      end

      it 'should persist the first cart_item' do
        expect(cart_item1).to be_persisted
      end

      it 'should persist the second cart_item' do
        expect(cart_item2).to be_persisted
      end
    end
  end

  describe '#gross_total' do
    context 'with discounted items' do
      let(:cart)  { create :cart }
      let(:item1) { create :item_with_discount, price: 10.0 }
      let(:item2) { create :item_with_discount, price: 20.0 }

      before :each do
        cart.add item1, 2
        cart.add item2, 2
      end

      subject(:gross_total) { cart.gross_total }

      # Check the factory discount value
      it 'should discount the products with the 10%' do
        expect(item1.item_category.discount).to eq 10.0
        expect(item2.item_category.discount).to eq 10.0
      end

      it 'should equal to the discounted items price by the relative categories' do
        is_expected.to eq (9.0 * 2 + 18.0 * 2)
      end
    end

    context 'with items without discounts' do
      let(:cart)  { create :cart }
      let(:item1) { create :item_without_discount, price: 10.0 }
      let(:item2) { create :item_without_discount, price: 20.0 }

      before :each do
        cart.add item1, 2
        cart.add item2, 2
      end

      subject(:gross_total) { cart.gross_total }

      it 'should equal to the full items price' do
        is_expected.to eq 60.0
      end
    end
  end

  describe '#apply_volume_discount?' do
    let!(:cart)  { create :cart }
    subject { cart.apply_volume_discount? }

    context "when the Cart#gross_total is greater than #{Cart::MIN_PRICE_VOLUME_DISCOUNT}" do
      before :each do
        allow(cart).to receive(:gross_total) { Cart::MIN_PRICE_VOLUME_DISCOUNT + 100 }
      end

      it { is_expected.to be true }
    end

    context "when the Cart#gross_total is less than #{Cart::MIN_PRICE_VOLUME_DISCOUNT}" do
      before :each do
        allow(cart).to receive(:gross_total) { Cart::MIN_PRICE_VOLUME_DISCOUNT - 1 }
      end

      it { is_expected.to be false }
    end

    context "when the Cart#gross_total is equal to #{Cart::MIN_PRICE_VOLUME_DISCOUNT}" do
      before :each do
        allow(cart).to receive(:gross_total) { Cart::MIN_PRICE_VOLUME_DISCOUNT }
      end

      it { is_expected.to be false }
    end
  end

  describe '#volume_discount_amount' do
    let(:cart)  { create :cart_with_items }
    subject { cart.volume_discount_amount }

    before :each do
      allow(cart).to receive(:gross_total) { 100.0 }
    end

    it { is_expected.to eq Cart::VOLUME_DISCOUNT }
  end

  describe '#raw_final_price' do
    let(:cart) { create :cart_with_items }
    subject { cart.raw_final_price }

    context "when the gross_total amount exceeds #{Cart::MIN_PRICE_VOLUME_DISCOUNT} euros" do
      let(:highter_gross_total) { Cart::MIN_PRICE_VOLUME_DISCOUNT + 10 }
      let(:expected_final_price) { highter_gross_total - (highter_gross_total * Cart::VOLUME_DISCOUNT / 100) }

      before :each do
        allow(cart).to receive(:gross_total) { highter_gross_total }
      end

      it { is_expected.to eq expected_final_price}
    end

    context "when the gross_total amount doesn't exceeds #{Cart::MIN_PRICE_VOLUME_DISCOUNT} euros" do
      let(:lower_gross_total) { Cart::MIN_PRICE_VOLUME_DISCOUNT - 10 }

      before :each do
        allow(cart).to receive(:gross_total) { lower_gross_total }
      end

      it { is_expected.to eq lower_gross_total}
    end
  end

  describe '#rounded_final_price' do
    let(:cart) { create :cart_with_items }
    test_values = {
      10.12 => 10.10,
      10.24 => 10.25,
      10.25 => 10.25,
      10.33 => 10.35,
      10.53 => 10.55,
      10.65 => 10.65,
      10.75 => 10.75,
      10.84 => 10.85,
      10.89 => 10.90
    }

    test_values.each do |raw_value, rounded_value|
      it "should round #{raw_value} into #{rounded_value}" do
        allow(cart).to receive(:raw_final_price) { raw_value }
        expect(cart.rounded_final_price).to eq rounded_value
      end
    end
  end
end
