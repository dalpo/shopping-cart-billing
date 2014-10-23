# Shopping cart billing

Billing of the shopping cart needs to be done applying the discounts on each discounted item. Discounts are determined by the type of the item.
Grocery items get 7.5% discount, Books get 12% discount. If the total bill amount exceeds 40 euros additional 5% discount is applied on overall total.

Bill should display unit price, discount %, final price and final total and total discount. Final total should be rounded off to nearest 5 cents. Price per unit is given.

Write an application that prints out the receipt details for these shopping baskets.

### Requirements:

- Ruby 2.0.0 or higher (recommend the use of RVM: http://rvm.io/)

- Bundler gem (`gem install bundler`)


### Application setup:

```bash
bash$ git clone git@github.com:dalpo/shopping-cart-billing.git

bash$ cd shopping-cart-billing

bash$ bundle install

bash$ bundle exec rake db:setup

bash$ rails server
```

### Run unit testing:

```bash
bash$ bundle exec rake spec
```