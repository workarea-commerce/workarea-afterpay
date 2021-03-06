module Workarea
  module Admin
    class AfterpayConfigurationViewModel < ApplicationViewModel
      include Storefront::AfterpayConfiguration

      def au_limits
        return unless Workarea::Afterpay.merchant_id(:au).present?
        limits = afterpay_configuration(:au)
        {
          min: min_price(limits),
          max: max_price(limits)
        }
      end

      def us_limits
        return unless Workarea::Afterpay.merchant_id(:us).present?
        limits = afterpay_configuration(:us)
        {
          min: min_price(limits),
          max: max_price(limits)
        }
      end

      private

        def min_price(limits)
          return 0.to_m unless limits.present? && limits["minimumAmount"].present?
          limits["minimumAmount"]["amount"].to_m
        end

        def max_price(limits)
          return unless limits.present?
          limits["maximumAmount"]["amount"].to_m
        end
    end
  end
end
