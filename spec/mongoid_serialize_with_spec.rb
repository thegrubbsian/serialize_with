require "spec_helper"

module MongoidSpec

  class Order
    include Mongoid::Document
    include Mongoid::SerializeWith
    serialize_with :private, include: [:customer]
    embeds_many :order_items
    belongs_to :customer
    field :order_total
  end

  class OrderItem
    include Mongoid::Document
    include Mongoid::SerializeWith
    serialize_with methods: [:tax_amount], include: [:product]
    embedded_in :order
    belongs_to :product
    field :product_sku
    field :quantity, type: Integer
    field :price, type: Float
    def tax_amount; price * 0.09 end
    def apple_tax_amount; price * 999 end
  end

  class Product
    include Mongoid::Document
    include Mongoid::SerializeWith
    serialize_with only: [:name, :price]
    field :name
    field :sku
    field :manufacturer
    field :price, type: Float
  end

  class Customer
    include Mongoid::Document
    include Mongoid::SerializeWith
    serialize_with except: [:last_name]
    has_many :orders
    field :first_name
    field :last_name
    field :address
  end

end

describe "SerializeWith Mongoid" do

  before do
    MongoidSpec::Customer.delete_all
    MongoidSpec::Order.delete_all
    MongoidSpec::OrderItem.delete_all

    @customer = MongoidSpec::Customer.create!(last_name: "Smith", first_name: "Carol", address: "123 Address Street")
    @product = MongoidSpec::Product.create!(name: "Banana", price: 140.00, sku: "sdfh3j234k")
    @order_item = MongoidSpec::OrderItem.new(quantity: 7000, product_id: @product.id, product_sku: "skdjfhkjwehr", price: 50.00)
    @order = MongoidSpec::Order.create!(customer_id: @customer.id, order_total: 400, order_items: [@order_item])
  end

  describe "default context" do

    context "when serialize_with is given an include option it" do

      it "returns the association" do
        @order.as_json[:order_items].should == [@order_item.as_json]
      end

      it "allows default and local configuration" do
        json = @order.as_json(include: [:customer])
        json[:customer].should == @customer.as_json
        json[:order_items].should == [@order_item.as_json]
      end

    end

    context "when serialize_with is given a methods option it" do

      it "returns the method" do
        @order_item.as_json[:tax_amount].should == @order_item.tax_amount
      end

      it "allows default and local configuration" do
        json = @order_item.as_json(methods: [:apple_tax_amount])
        json[:tax_amount].should == @order_item.tax_amount
        json[:apple_tax_amount].should == @order_item.apple_tax_amount
      end

    end

    context "when serialize_with is given an except option it" do

      it "does not return the specified property" do
        @customer.as_json["last_name"].should be_nil
      end

      it "allows local configuration to override the default" do
        json = @customer.as_json(except: [:first_name])
        json["first_name"].should be_nil
        json["last_name"].should == @customer.last_name
      end

    end

    context "when serialize_with is given an only option" do

      it "returns only the specified properties" do
        @product.as_json.keys.sort.should == ["name", "price"]
      end

      it "allows local configuration to override the default" do
        json = @product.as_json(only: [:price, :sku])
        json.keys.sort.should == ["price", "sku"]
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

  # This is not standard as the built-in serialization logic returns
  # method, includes, except, and only properties with different key
  # types.
  it "returns a hash that can be accessed with strings or symbol keys" do
    json = @order.as_json(:private)
    json["customer"].should == @customer.as_json
    json[:customer].should == @customer.as_json
  end

end
