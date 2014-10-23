FactoryGirl.define do
  factory :item do
    name "Sample product"
    price 9.99

    factory :item_with_category do
      item_category
    end

    factory :item_with_discount do
      association :item_category, factory: :item_category_with_discount
    end

    factory :item_without_discount do
      association :item_category, factory: :item_category_without_discount
    end
  end
end
