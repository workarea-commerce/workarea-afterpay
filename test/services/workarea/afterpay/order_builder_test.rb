require 'test_helper'

module Workarea
  module Afterpay
    class OrderBuilderTest < Workarea::TestCase

      def test_build
        create_order_total_discount
        order = create_order

        # apply store credit
        payment = Workarea::Payment.find(order.id)
        payment.profile.update_attributes!(store_credit: 1.00)
        payment.set_store_credit
        payment.tenders.first.amount = 1.to_m
        payment.save

        order.reload
        payment.reload
        order_hash = Workarea::Afterpay::OrderBuilder.new(order).build

        assert_equal(9.00, order_hash[:amount][:amount].to_f)
        assert_equal(1.00, order_hash[:shippingAmount][:amount].to_f)
        assert_equal(0.00, order_hash[:taxAmount][:amount].to_f)
        assert_equal(order.id, order_hash[:merchantReference])

        assert_equal("bcrouse-new@workarea.com", order_hash[:consumer][:email])
        assert_equal("Ben", order_hash[:consumer][:givenNames])
        assert_equal("Crouse", order_hash[:consumer][:surname])

        assert_equal(1, order_hash[:discounts].size)
        assert_equal("Order Total Discount", order_hash[:discounts].first[:displayName])

        assert_equal("Philadelphia", order_hash[:shipping][:area1])
        assert_equal("Wilmington", order_hash[:billing][:area1])

        assert_equal(1, order_hash[:items].size)
        assert_equal("SKU", order_hash[:items].first[:sku])
        assert_equal(2, order_hash[:items].first[:quantity])
        assert_equal(5, order_hash[:items].first[:price][:amount].to_f)
      end

      private

      def create_order(overrides = {})
        attributes = {
          id: '1234',
          email: 'bcrouse-new@workarea.com',
          placed_at: Time.current
        }.merge(overrides)

        shipping_service = create_shipping_service
        product = create_product(variants: [{ sku: 'SKU', regular: 5.to_m }])

        order = Workarea::Order.new(attributes)
        order.add_item(product_id: product.id, sku: 'SKU', quantity: 2)

        checkout = Checkout.new(order)
        checkout.update(
          shipping_address: {
            first_name: 'Ben',
            last_name: 'Crouse',
            street: '22 S. 3rd St.',
            street_2: 'Second Floor',
            city: 'Philadelphia',
            region: 'PA',
            postal_code: '19106',
            country: 'US'
          },
          billing_address: {
            first_name: 'Bob',
            last_name: 'Clams',
            street: '12 N. 3rd St.',
            street_2: 'Second Floor',
            city: 'Wilmington',
            region: 'DE',
            postal_code: '18083',
            country: 'US'
          },
          shipping_service: shipping_service.name,
        )

        order
      end
    end
  end
end
