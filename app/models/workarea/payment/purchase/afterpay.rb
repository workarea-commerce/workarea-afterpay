module Workarea
  class Payment
    module Purchase
      class Afterpay
        include OperationImplementation
        include CreditCardOperation
        include AfterpayPaymentGateway

        def complete!
          response = purchase
          if response.success?
            transaction.response = ActiveMerchant::Billing::Response.new(
              true,
              I18n.t(
                'workarea.afterpay.purchase',
                amount: transaction.amount
              ),
              response.body
            )
          else
             transaction.response = ActiveMerchant::Billing::Response.new(
               false,
              I18n.t('workarea.afterpay.purchase_failure'),
              response.body
            )
          end
        end

        def cancel!
          # No op - no cancel functionality available.
        end

        private

        def purchase
          request_id = SecureRandom.uuid
          purchase_response = response(request_id)

          if Workarea::Afterpay::RETRY_ERROR_STATUSES.include? purchase_response.status
            return response(request_id)
          end

          purchase_response
        end

        def response(request_id)
          gateway.purchase(tender.token, request_id)
        end
      end
    end
  end
end
