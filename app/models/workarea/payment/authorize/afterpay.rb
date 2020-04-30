module Workarea
  class Payment
    module Authorize
      class Afterpay
        include OperationImplementation
        include CreditCardOperation
        include AfterpayPaymentGateway

        def complete!
          response = authorize
          if response.success? && response.body['status'] == 'APPROVED'
            transaction.response = ActiveMerchant::Billing::Response.new(
              true,
              I18n.t(
                'workarea.afterpay.authorize',
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
          return unless transaction.success?

          payment_id = transaction.response.params["id"]
          response = gateway.void(payment_id)

          transaction.cancellation = ActiveMerchant::Billing::Response.new(
            true,
              I18n.t('workarea.afterpay.void'),
              response.body
            )
        end

        private

        def authorize
          request_id = SecureRandom.uuid
          auth_response = response(request_id)
          if Workarea::Afterpay::RETRY_ERROR_STATUSES.include? auth_response.status
            return response(request_id)
          end

          auth_response
        end

        def response(request_id)
          gateway.authorize(tender.token, tender.payment.id, request_id)
        end
      end
    end
  end
end
