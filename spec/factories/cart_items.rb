FactoryGirl.define do
  factory :cart_item do
    cart
    item
    size 1
  end
end
