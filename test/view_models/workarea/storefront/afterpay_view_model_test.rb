require 'test_helper'

module Workarea
  module Storefront
    class AfterpayViewModelTest < TestCase
      setup :set_checkout

      def set_checkout
        @order = Order.new(email: 'bcrouse@workarea.com')
        @user = User.new(email: 'bcrouse@workarea.com')
      end

      def test_order_total_in_range
        @order.total_price = 25.00

        checkout = Workarea::Checkout.new(@order, @user)
        view_model = Workarea::Storefront::AfterpayViewModel.new(checkout, { afterpay_configuration: afterpay_options, order: @order })

        assert(view_model.order_total_in_range?)

        @order.total_price = 15.00
        view_model = Workarea::Storefront::AfterpayViewModel.new(checkout, { afterpay_configuration: afterpay_options, order: @order })
        refute(view_model.order_total_in_range?)
      end

      def test_show?
        settings = Workarea::Afterpay::Configuration.create!

        @order.total_price = 25.00
        view_model = Workarea::Storefront::AfterpayViewModel.new(nil, { afterpay_configuration: afterpay_options, order: @order })
        assert(view_model.show?)

        settings.enabled = false
        settings.save!
        view_model = Workarea::Storefront::AfterpayViewModel.new(nil, { afterpay_configuration: afterpay_options, order: @order })
        refute(view_model.show?)

        @order.total_price = 25.00.to_m("EUR")
        view_model = Workarea::Storefront::AfterpayViewModel.new(nil, { afterpay_configuration: afterpay_options, order: @order })
        refute(view_model.show?)

        Workarea::Order.any_instance.stubs(:currency).returns("EUR")
        @order.total_price = 25.00
        view_model = Workarea::Storefront::AfterpayViewModel.new(nil, { afterpay_configuration: afterpay_options, order: @order })
        refute(view_model.show?)
      end

      def test_afterpay_country
        checkout = Workarea::Checkout.new(@order, @user)

        @order.total_price = 25.00
        view_model = Workarea::Storefront::AfterpayViewModel.new(checkout, { afterpay_configuration: afterpay_options, order: @order })
        assert_equal('US', view_model.afterpay_country)

        @order.total_price = 25.00.to_m('AUD')
        view_model = Workarea::Storefront::AfterpayViewModel.new(checkout, { afterpay_configuration: afterpay_options, order: @order })
        assert_equal('AU', view_model.afterpay_country)

        @order.total_price = 25.00.to_m('EUR')
        view_model = Workarea::Storefront::AfterpayViewModel.new(checkout, { afterpay_configuration: afterpay_options, order: @order })
        refute(view_model.afterpay_country.present?)
      end

      def test_display_options
        @order.total_price = 25.00

        checkout = Workarea::Checkout.new(@order, @user)
        view_model = Workarea::Storefront::AfterpayViewModel.new(checkout, { afterpay_configuration: afterpay_options, order: @order })

        assert_equal("PAY_BY_INSTALLMENT", view_model.display_option[:type])
        assert_equal("Pay over time", view_model.display_option[:description])
      end

      def test_installment_price
        @order.total_price = 100.00
        view_model = Workarea::Storefront::AfterpayViewModel.new(nil, { afterpay_configuration: afterpay_options, order: @order })

        assert_equal(25.00, view_model.installment_price.amount)
      end

      private
        def afterpay_options
          [
            {
              "type": "PAY_BY_INSTALLMENT",
              "description": "Pay over time",
              "minimumAmount": {
                   "amount": "20.00",
                   "currency": "USD"
               },
              "maximumAmount": {
                  "amount": "30.00",
                  "currency": "USD"
              }
            }
          ]
        end
    end
  end
end
