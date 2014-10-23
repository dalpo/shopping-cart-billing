FactoryGirl.define do
  factory :item_category do
    name "Product category"
    discount 1.5

    factory :item_category_with_discount do
      discount 10.0
    end

    factory :item_category_without_discount do
      discount 0.0
    end
  end
end
