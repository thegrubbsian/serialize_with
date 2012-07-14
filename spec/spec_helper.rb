ENV["RAILS_ENV"] = "development"

require "rubygems"
require "active_record"
require "serialize_with"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Migration.verbose = false
ActiveRecord::Base.include_root_in_json = false

migration = Class.new(ActiveRecord::Migration) do
  def change
    create_table :customers, :force => true do |t|
      t.string :first_name
      t.string :last_name
      t.string :address
    end
    create_table :products, :force => true do |t|
      t.string :name
      t.string :sku
      t.string :manufacturer
      t.decimal :price
    end
    create_table :orders, :force => true do |t|
      t.integer :customer_id
      t.decimal :order_total
    end
    create_table :order_items, :force => true do |t|
      t.integer :order_id
      t.string :product_sku
      t.integer :quantity
      t.integer :product_id
      t.decimal :price
    end
  end
end

migration.new.migrate(:up)

RSpec.configure do |config|
  config.mock_with :rspec
end

ActiveSupport.on_load(:active_record) do
  self.extend SerializeWith
end
