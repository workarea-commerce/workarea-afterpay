require 'test_helper'

module Workarea
  module Storefront
    class AfterpayIntengrationTest < Workarea::IntegrationTest
      setup do
        create_tax_category(
          name: 'Sales Tax',
          code: '001',
          rates: [{ percentage: 0.07, country: 'US', region: 'PA' }]
        )

        product = create_product(
          variants: [{ sku: 'SKU1', regular: 6.to_m, tax_code: '001' }]
        )

        create_shipping_service(
          carrier: 'UPS',
          name: 'Ground',
          service_code: '03',
          tax_code: '001',
          rates: [{ price: 7.to_m }]
        )

        post storefront.cart_items_path,
          params: {
            product_id: product.id,
            sku: product.skus.first,
            quantity: 2
          }

        patch storefront.checkout_addresses_path,
          params: {
            email: 'bcrouse@workarea.com',
            billing_address: {
              first_name:   'Ben',
              last_name:    'Crouse',
              street:       '12 N. 3rd St.',
              city:         'Philadelphia',
              region:       'PA',
              postal_code:  '19106',
              country:      'US',
              phone_number: '2159251800'
            },
            shipping_address: {
              first_name:   'Ben',
              last_name:    'Crouse',
              street:       '22 S. 3rd St.',
              city:         'Philadelphia',
              region:       'PA',
              postal_code:  '19106',
              country:      'US',
              phone_number: '2159251800'
            }
          }

        patch storefront.checkout_shipping_path
      end

      def test_start_adds_a_token_to_payment
        get storefront.start_afterpay_path

        payment = Payment.find(order.id)
        payment.reload

        assert(payment.afterpay.present?)

        order.reload

        assert(order.afterpay_token.present?)
      end

      def test_start_clears_credit_card
        payment = Payment.find(order.id)
        payment.set_credit_card({
          month: "01",
          year: Time.now.year + 1,
          number: 1,
          cvv: "123"
        })

        payment.reload

        get storefront.start_afterpay_path

        payment.reload
        order.reload

        refute(payment.credit_card.present?)
        assert(payment.afterpay.present?)
        assert(order.afterpay_token.present?)
      end

      def test_cancel_removes_afterpay
        payment = Payment.find(order.id)

        payment.set_afterpay(token: '1234')

        assert(payment.afterpay?)

        get storefront.cancel_afterpay_path(token: '1234')
        payment.reload

        refute(payment.afterpay?)
      end

      def test_handling_afterpay_payment_error
        payment = Payment.find(order.id)

        payment.set_afterpay(token: '1234')

        params = { token: '1234', status: 'ERROR' }
        get storefront.complete_afterpay_path(params)

        payment.reload
        refute(payment.afterpay?)
      end

      def test_placing_order_from_afterpay
        Workarea::Afterpay::BogusGateway.any_instance.stubs(:get_order).returns(get_order_response(order.total_price.to_s))

        payment = Payment.find(order.id)

        payment.set_afterpay(token: '1234')

        params = { token: '1234', status: 'SUCCESS' }

        get storefront.complete_afterpay_path(params)

        payment.reload
        order.reload

        assert(order.placed?)

        transactions = payment.tenders.first.transactions
        assert_equal(1, transactions.size)
        assert(transactions.first.success?)
        assert_equal('authorize', transactions.first.action)
      end


      def test_placing_order_from_afterpay_with_invalid_order_total
        Workarea::Afterpay::BogusGateway.any_instance.stubs(:get_order).returns(get_order_response("5.00"))

        payment = Payment.find(order.id)

        payment.set_afterpay(token: '1234')

        params = { token: '1234', status: 'SUCCESS' }

        get storefront.complete_afterpay_path(params)

        payment.reload
        order.reload

        refute(order.placed?)
      end

      def test_placing_order_with_dual_payment
        payment = Payment.find(order.id)
        payment.profile = create_payment_profile(email: order.email)

        payment.profile.update_attributes!(store_credit: 1.00)
        payment.set_store_credit
        payment.tenders.first.amount = 1.to_m
        payment.save!

        payment.set_afterpay(token: '1234')

        params = { token: '1234', status: 'SUCCESS' }

        ap_balance = order.total_price - 1.to_m
        Workarea::Afterpay::BogusGateway.any_instance.stubs(:get_order).returns(get_order_response(ap_balance.to_s))

        get storefront.complete_afterpay_path(params)

        payment.reload
        order.reload

        assert(order.placed?)
        transactions = payment.transactions
        assert_equal(2, transactions.size)

        ap_tender = payment.tenders.detect { |t| t.slug == :afterpay }
        assert(ap_tender.transactions.first.success?)
        assert_equal('authorize', ap_tender.transactions.first.action)

        sc_tender = payment.tenders.detect { |t| t.slug == :store_credit }
        assert(sc_tender.transactions.first.success?)

        # Workarea v3.0.53, v3.1.40, v3.2.29, v3.3.21 and greater sets store credit to purchase by default.
        assert_equal('purchase', sc_tender.transactions.first.action)
      end

      def test_failed_afterpay_capture
        payment = Payment.find(order.id)

        payment.set_afterpay(token: 'error_token')

        params = { token: 'error_token', status: 'SUCCESS' }

        get storefront.complete_afterpay_path(params)

        payment.reload
        order.reload

        refute(order.placed?)
      end

      private

      def order
         @order ||= Order.first
       end

      def product
        @product ||= create_product(
          variants: [{ sku: 'SKU1', regular: 6.to_m, tax_code: '001' }]
        )
      end

      def get_order_response(amount)
        b = {
              "amount": {
                "amount": "#{amount}",
                "currency": "USD"
              }
            }
          Workarea::Afterpay::Response.new(response(b))
      end

      def response(body, status = 200)
        response = Faraday.new do |builder|
          builder.adapter :test do |stub|
            stub.get("/v2/bogus") { |env| [ status, {}, body.to_json ] }
          end
        end
        response.get("/v2/bogus")
      end
    end
  end
end
