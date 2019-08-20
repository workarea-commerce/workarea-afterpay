module Workarea
  class Payment
    class Refund
      class Afterpay
        include OperationImplementation
        include CreditCardOperation

        def complete!
          request_id = SecureRandom.uuid

          response = gateway.refund(afterpay_order_id, transaction.amount, request_id)

          if response.success?
            transaction.response = ActiveMerchant::Billing::Response.new(
              true,
              I18n.t(
                'workarea.afterpay.refund',
                amount: transaction.amount
              ),
              response.body
            )
          else
             transaction.response = ActiveMerchant::Billing::Response.new(
               false,
              I18n.t('workarea.afterpay.refund_failure'),
              response.body
            )
          end
        end

        def cancel!
          # No op - no cancel functionality available.
        end

        private

          def gateway
            currency = transaction.amount.currency.iso_code
            location = Workarea::Afterpay.config[:currency_country_map][currency.to_sym]

            location = location.to_sym.downcase

            Workarea::Afterpay.gateway(location)
          end

          def afterpay_order_id
            transaction.reference.response.params["id"]
          end
      end
    end
  end
end
