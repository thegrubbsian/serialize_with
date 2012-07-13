require "spec_helper"

ActiveSupport.on_load(:active_record) do
  self.extend SerializeWith
end

class Order < ActiveRecord::Base
  serialize_with include: [:order_items]
  has_many :order_items
  belongs_to :customer
end

class OrderItem < ActiveRecord::Base
  serialize_with methods: [:tax_amount]
  belongs_to :order
  def tax_amount; price * 0.09 end
  def apple_tax_amount; price * 999 end
end

class Customer < ActiveRecord::Base
  serialize_with except: [:last_name]
  has_many :orders
end

describe SerializeWith do

  before do
    @customer = Customer.create!(last_name: "Smith", first_name: "Carol", address: "123 Address Street")
    @order = Order.create!(customer_id: @customer.id, order_total: 400)
    @order_item = OrderItem.create!(order_id: @order.id, quantity: 7000, product_sku: "skdjfhkjwehr", price: 50.00)
  end

  context "when serialize_with is given an include option" do

    it "it correctly includes the association" do
      @order.as_json[:order_items].should == [@order_item.as_json]
    end

    it "and a local as_json include option both includes are respected" do
      json = @order.as_json(include: [:customer])
      json[:customer].should == @customer.as_json
      json[:order_items].should == [@order_item.as_json]
    end

  end

  context "when serialize_with is given a methods option" do

    it "it correctly includes the method" do
      @order_item.as_json[:tax_amount].should == @order_item.tax_amount
    end

    specify "and a local as_json include option both includes are respected" do
      json = @order_item.as_json(methods: [:apple_tax_amount])
      json[:tax_amount].should == @order_item.tax_amount
      json[:apple_tax_amount].should == @order_item.apple_tax_amount
    end

  end

  context "when serialize_with is given an except option" do

    specify "it correctly excludes the property" do
      @customer.as_json["last_name"].should be_nil
    end

    specify "and a local as_json include option both includes are respected" do
      @customer.as_json(except: [:first_name])["first_name"].should be_nil
    end

  end

  describe "uber test of all-emcompassing uberness" do

    specify "includes model and local includes, excludes model excludes and local excludes, and gets local methods and model methods" do
      @customer.as_json(include: [:orders])[:orders].should == [@order.as_json]
    end

  end

end
