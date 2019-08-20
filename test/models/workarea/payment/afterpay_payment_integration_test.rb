require 'test_helper'

module Workarea
  class AfterpayPaymentIntegrationTest < Workarea::TestCase

    def test_capture
      tender.amount = 5.to_m
      transaction = tender.build_transaction(action: 'capture')
      transaction.save!

      operation = Payment::Capture::Afterpay.new(tender, transaction)
      operation.complete!

      assert(transaction.success?, 'expected transaction to be successful')
    end

    def test_auth
      transaction = tender.build_transaction(action: 'authorize')
      Payment::Authorize::Afterpay.new(tender, transaction).complete!
      assert(transaction.success?, 'expected transaction to be successful')
    end

    def test_purchase
      transaction = tender.build_transaction(action: 'purchase')
      Payment::Purchase::Afterpay.new(tender, transaction).complete!
      assert(transaction.success?)
    end

    private

      def gateway
        Workarea.Afterpay.gateay
      end

      def payment
        @payment ||=
          begin
            profile = create_payment_profile
            create_payment(
              profile_id: profile.id,
              address: {
                first_name: 'Ben',
                last_name: 'Crouse',
                street: '22 s. 3rd st.',
                city: 'Philadelphia',
                region: 'PA',
                postal_code: '19106',
                country: Country['US']
              }
            )
          end
      end

      def tender
        @tender ||=
          begin
            payment.set_address(first_name: 'Ben', last_name: 'Crouse')

            payment.build_afterpay(
              token: '12345'
            )

            payment.afterpay
          end
      end
  end
end
