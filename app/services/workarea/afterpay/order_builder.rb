module Workarea
  module Afterpay
    class OrderBuilder

      attr_reader :order

      # @param  ::Workarea::Order
      def initialize(order)
        @order = Workarea::Storefront::OrderViewModel.new(order)
      end

      def build
        {
          totalAmount: {
            amount: order.order_balance.to_s,
            currency: currency_code,
          },
          merchantReference: order.id,
          consumer: {
            phoneNumber: shipping.address.phone_number,
            givenNames: shipping.address.first_name,
            surname: shipping.address.last_name,
            email: order.email
          },
          billing: address(payment.address),
          shipping: address(shipping.address),
          items: items,
          discounts: discounts,
          merchant: {
             redirectConfirmUrl: confirm_url,
             redirectCancelUrl: cancel_url
          },
           taxAmount: {
             amount: order.tax_total.to_s,
             currency: currency_code
          },
          shippingAmount: {
              amount: order.shipping_total.to_s,
              currency: currency_code
          }
        }
      end

      private

        def currency_code
          @currency_code = order.total_price.currency.iso_code
        end

        def shipping
          @shipping = Workarea::Shipping.find_by_order(order.id)
        end

        def payment
          @payment = Workarea::Payment.find(order.id)
        end

        def address(address_obj)
          {
            name: "#{address_obj.first_name} #{address_obj.last_name}",
            suburb: address_obj.city,
            line1: address_obj.street,
            state: address_obj.region,
            postcode: address_obj.postal_code,
            countryCode: address_obj.country.alpha2,
            phoneNumber:  address_obj.phone_number
          }
        end

        def items
          order.items.map do |oi|
            product = Workarea::Catalog::Product.find_by_sku(oi.sku)
            {
              name: product.name,
              sku: oi.sku,
              quantity: oi.quantity,
              price: {
                amount: oi.original_unit_price.to_s,
                currency: currency_code
              }
            }
          end
        end

        def discounts
          discounts = order.price_adjustments.select { |p| p.discount? }
          discounts.map do |d|
            {
              displayName: d.description,
              amount: {
                amount: d.amount.abs.to_s,
                currency: currency_code
              }
            }
          end
        end

        def confirm_url
          Storefront::Engine.routes.url_helpers.complete_afterpay_url(host: Workarea.config.host)
        end

        def cancel_url
          Storefront::Engine.routes.url_helpers.cancel_afterpay_url(host: Workarea.config.host)
        end
    end
  end
end
