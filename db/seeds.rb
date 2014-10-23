# Product items:
grocery_category = ItemCategory.create name: 'Grocery', discount: 7.5
books_category   = ItemCategory.create name: 'Books',   discount: 12.0

pasta1kg = Item.create!({
  item_category: grocery_category,
  name:   '1 Pasta 1kg',
  price:  4.29
})

book = Item.create!({
  item_category: books_category,
  name:   'Book',
  price:  10.12
})

coffee = Item.create!({
  item_category: grocery_category,
  name:   'Coffee 500g',
  price:  3.21
})

cake = Item.create!({
  name:   'Cake',
  price:  2.35
})

chocolate = Item.create!({
  name:   'Chocolate',
  price:  2.1
})

wine = Item.create!({
  name:   'Wine',
  price:  10.5
})

another_book = Item.create!({
  item_category: books_category,
  name:   'Book',
  price:  15.05
})

apple = Item.create!({
  name:   'Apple',
  price:  0.5
})


##
# Input 1:
# 1 Pasta 1kg at 4.29
# 1 Book at 10.12
first_cart = Cart.create.tap do |cart|
  cart.add pasta1kg
  cart.add book
  cart.checkout!
end


##
# Input 2:
# 1 Coffee 500g at 3.21
# 1 Pasta 1Kg at 4.29
# 1 Cake at 2.35
second_cart = Cart.create.tap do |cart|
  cart.add coffee
  cart.add pasta1kg
  cart.add cake
  cart.checkout!
end


##
# Input 3:
# 10 Chocolate at 2.1
# 1 Wine at 10.5
# 1 Book at 15.05
# 5 Apple at 0.5
third_cart = Cart.create.tap do |cart|
  cart.add chocolate, 10
  cart.add wine
  cart.add another_book
  cart.add apple, 5
  cart.checkout!
end
