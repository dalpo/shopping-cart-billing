class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.string   :status
      t.datetime :billed_at
      t.decimal  :final_price, precision: 8, scale: 2

      t.timestamps
    end
  end
end
