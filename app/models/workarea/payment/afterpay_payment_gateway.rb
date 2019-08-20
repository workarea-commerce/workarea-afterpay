module Workarea
  class Payment
    module AfterpayPaymentGateway
      # Examines the tenders currency and selects the
      # correct credentials to use in the gateway
      #
      # @return Workarea::Afterpay::Gateway
      def gateway
        currency = tender.amount.currency.iso_code
        location = Afterpay.config[:currency_country_map][currency.to_sym]

        Afterpay.gateway(location.to_sym.downcase)
      end
    end
  end
end
