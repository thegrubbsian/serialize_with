require "spec_helper"

class Order < ActiveRecord::Base
  serialize_with include: [:order_items]
  serialize_with :private, include: [:order_items, :customer]
  has_many :order_items
  belongs_to :customer
end

class OrderItem < ActiveRecord::Base
  serialize_with methods: [:tax_amount], include: [:product]
  belongs_to :order
  belongs_to :product
  def tax_amount; price * 0.09 end
  def apple_tax_amount; price * 999 end
end

class Product < ActiveRecord::Base; end

class Customer < ActiveRecord::Base
  serialize_with except: [:last_name]
  has_many :orders
  has_many :order_items, through: :orders
end

describe SerializeWith do

  before do
    Customer.delete_all
    Order.delete_all
    OrderItem.delete_all

    @customer = Customer.create!(last_name: "Smith", first_name: "Carol", address: "123 Address Street")
    @order = Order.create!(customer_id: @customer.id, order_total: 400)
    @product = Product.create!(name: "Banana")
    @order_item = OrderItem.create!(order_id: @order.id, quantity: 7000, product_id: @product.id,
                                    product_sku: "skdjfhkjwehr", price: 50.00)
  end

  describe "default context" do

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

  end

  describe "alternate contexts" do

    it "apply the correct serialization rules" do
      @order.as_json.should_not include(:customer)
      @order.as_json(:private)[:customer].should == @customer.as_json
    end

    it "respects the context and local rules" do
      json = @order.as_json(:private, except: [:order_total])
      json[:customer].should == @customer.as_json
      json["order_total"].should be_nil
    end

  end

  it "all works together as expected :)" do
    json = @customer.as_json(include: [:order_items])
    json[:last_name].should be_nil
    json[:order_items].should == [@order_item.as_json]
    json[:order_items][0][:product].should == @product.as_json
  end

end
