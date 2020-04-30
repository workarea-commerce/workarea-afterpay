module Workarea
  class Payment
    class Capture
      class Afterpay
        include OperationImplementation
        include CreditCardOperation
        include AfterpayPaymentGateway

        def complete!
          response = capture
          if response.success? && response.body['status'] == 'APPROVED'
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

        private
          def payment_id
            transaction.reference.response.params["id"]
          end

          def capture
            request_id = SecureRandom.uuid
            capture_response = response(request_id)

            if Workarea::Afterpay::RETRY_ERROR_STATUSES.include? capture_response.status
              return response(request_id)
            end

            capture_response
          end

          def response(request_id)
            gateway.capture(payment_id, transaction.amount, request_id)
          end
      end
    end
  end
end
