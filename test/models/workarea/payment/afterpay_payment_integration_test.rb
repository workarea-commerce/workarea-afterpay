require 'test_helper'

module Workarea
  class AfterpayPaymentIntegrationTest < Workarea::TestCase
    def test_auth_capture
      transaction = tender.build_transaction(action: 'authorize')
      Payment::Purchase::Afterpay.new(tender, transaction).complete!

      assert(transaction.success?)
      transaction.save!

      assert(tender.token.present?)

      capture = Payment::Capture.new(payment: payment)
      capture.allocate_amounts!(total: 5.to_m)
      assert(capture.valid?)
      capture.complete!

      capture_transaction = payment.transactions.detect(&:captures)
      assert(capture_transaction.valid?)
    end

    def test_capture_decline
      transaction = tender.build_transaction(action: 'authorize')
      Payment::Authorize::Afterpay.new(tender, transaction).complete!

      # To force a decline response from capture API
      transaction.update!(
        response: ActiveMerchant::Billing::Response.new(
          true,
          'test',
          transaction.response.params.merge('id' => 'declined')
        )
      )

      capture = Payment::Capture.new(payment: payment)
      capture.allocate_amounts!(total: 5.to_m)
      assert(capture.valid?)
      refute(capture.complete!)

      capture_transaction = payment.reload.transactions.detect(&:capture?)
      refute(capture_transaction.success?)
      assert_equal('DECLINED', capture_transaction.response.params['status'])
    end

    def test_auth
      transaction = tender.build_transaction(action: 'authorize')
      Payment::Authorize::Afterpay.new(tender, transaction).complete!
      assert(transaction.success?, 'expected transaction to be successful')
    end

    def test_auth_decline
      tender.token = 'declined'
      transaction = tender.build_transaction(action: 'authorize')
      Payment::Authorize::Afterpay.new(tender, transaction).complete!

      refute(transaction.success?)
      assert_equal('DECLINED', transaction.response.params['status'])
    end

    def test_purchase
      transaction = tender.build_transaction(action: 'purchase')
      Payment::Purchase::Afterpay.new(tender, transaction).complete!
      assert(transaction.success?)
    end

    def test_purchase_decline
      tender.token = 'declined'
      transaction = tender.build_transaction(action: 'purchase')
      Payment::Purchase::Afterpay.new(tender, transaction).complete!

      refute(transaction.success?)
      assert_equal('DECLINED', transaction.response.params['status'])
    end

    def test_auth_void
      transaction = tender.build_transaction(action: 'authorize')
      operation = Payment::Authorize::Afterpay.new(tender, transaction)
      operation.complete!
      assert(transaction.success?, 'expected transaction to be successful')
      transaction.save!

      assert(tender.token.present?)
      operation.cancel!
      void = transaction.cancellation

      assert(void.success?)
    end

    def test_timeout_auth
      transaction = timeout_tender.build_transaction(action: 'authorize')
      operation = Payment::Authorize::Afterpay.new(timeout_tender, transaction)
      operation.complete!
      refute(transaction.success?, 'expected transaction to be a failure')
      transaction.save!

      assert(tender.token.present?)
    end


    private

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
              token: '12345',
              amount: 5.to_m
            )

            payment.afterpay
          end
      end

      def timeout_tender
        @tender ||=
          begin
            payment.set_address(first_name: 'Ben', last_name: 'Crouse')

            payment.build_afterpay(
              token: 'timeout_token'
            )

            payment.afterpay
          end
      end
  end
end
