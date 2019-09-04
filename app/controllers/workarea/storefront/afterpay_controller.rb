module Workarea
  class Storefront::AfterpayController < Storefront::ApplicationController
    include Storefront::CurrentCheckout

    before_action :validate_checkout

    def start
      self.current_order = current_checkout.order

      Pricing.perform(current_order, current_shipping)

      check_inventory || (return)
      # get a token for the current order
      order_payload = Afterpay::OrderBuilder.new(current_order).build
      response = gateway.create_order(order_payload)

      if !response.success?
        flash[:error] = t('workarea.storefront.afterpay.payment_error')
        redirect_to(checkout_payment_path) && (return)
      end

      token = response.body["token"]

      payment = Workarea::Payment.find(current_order.id)

      payment.clear_credit_card

      payment.set_afterpay(token: token)

      # set the token on the order so we can more easily look up the order
      # when returning from afterpay
      current_order.update_attributes!(afterpay_token: token)

      redirect_to checkout_payment_path
    end

    def complete
      self.current_order = Order.where(afterpay_token: params[:orderToken]).first
      payment = current_checkout.payment

      if params[:status] != "SUCCESS"
        flash[:error] = t('workarea.storefront.afterpay.payment_error')
        payment.clear_afterpay
        redirect_to(checkout_payment_path) && (return)
      end

      current_order.user_id = current_user.try(:id)
      check_inventory || (return)

      shipping = current_shipping

      Pricing.perform(current_order, shipping)
      payment.adjust_tender_amounts(current_order.total_price)

      ap_order_details = gateway.get_order(params[:orderToken])
      tender = payment.afterpay

      unless (ap_order_details.body["amount"]["amount"].to_m == tender.amount.to_m && current_checkout.complete?)
        flash[:error] = t('workarea.storefront.afterpay.payment_error')
        payment.clear_afterpay
        redirect_to(checkout_payment_path) && (return)
      end

      payment.afterpay.update_attributes!(ready_to_capture: true)

      # place the order.
      if current_checkout.place_order
        completed_place_order
      else
        incomplete_place_order
      end
    end

    def cancel
      self.current_order = Order.where(afterpay_token: params[:orderToken]).first

      current_order.user_id = current_user.try(:id)

      payment = current_checkout.payment
      payment.clear_afterpay

      flash[:success] = t('workarea.storefront.afterpay.cancel_message')

      redirect_to checkout_payment_path
    end

    private

      def gateway
        Afterpay.gateway(self.current_order.afterpay_location)
      end

      def completed_place_order
        Storefront::OrderMailer.confirmation(current_order.id).deliver_later
        self.completed_order = current_order
        clear_current_order

        flash[:success] = t('workarea.storefront.flash_messages.order_placed')
        redirect_to finished_checkout_destination
      end

      def incomplete_place_order
        if current_checkout.shipping.try(:errors).present?
          flash[:error] = current_checkout.shipping.errors.to_a.to_sentence
          redirect_to checkout_shipping_path
        else
          flash[:error] = t('workarea.storefront.afterpay.payment_error')

          payment = current_checkout.payment
          payment.clear_afterpay

          redirect_to checkout_payment_path
        end
      end

      def finished_checkout_destination
        if current_admin.present? && current_admin.orders_access?
          admin.order_path(completed_order)
        else
          checkout_confirmation_path
        end
      end
  end
end
