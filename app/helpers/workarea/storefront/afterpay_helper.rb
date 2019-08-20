module Workarea
  module Storefront
    module AfterpayHelper
      # get the relevant learn more link from
      # a price.
      #
      # @return String
      def learn_more_link(price)
        currency = price.currency.iso_code.to_sym
        location = Workarea::Afterpay.config[:currency_country_map][currency].to_sym.downcase
        return unless location.present?
        afterpay_dialog_path(location: location)
      end
    end
  end
end
