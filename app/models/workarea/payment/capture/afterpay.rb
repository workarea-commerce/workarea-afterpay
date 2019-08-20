module Workarea
  class Payment
    class Capture
      class Afterpay
        include OperationImplementation
        include CreditCardOperation
        include AfterpayPaymentGateway

        def complete!
          response = gateway.capture(tender.token, tender.payment.id)
          if response.success?
            transaction.response = ActiveMerchant::Billing::Response.new(
              true,
              I18n.t(
                'workarea.afterpay.capture',
                amount: transaction.amount
              ),
              response.body
            )
          else
             transaction.response = ActiveMerchant::Billing::Response.new(
               false,
              I18n.t('workarea.afterpay.capture_failure'),
              response.body
            )
          end
        end

        def cancel!
          # No op - no cancel functionality available.
        end
      end
    end
  end
end
