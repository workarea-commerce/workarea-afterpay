module Workarea
  module Storefront
    class AfterpayViewModel < ApplicationViewModel
    # Orders must be between the min and max order total to qualify.
    def order_total_in_range?
      return unless afterpay_configuration.present?
      order.order_balance >= min_price && order.order_balance <= max_price
    end

    # Show if admin settings are enabled, there are configuration options returned
    # from the API and the currency code is valid.
    def show?
      return unless afterpay_settings.enabled?
      return unless valid_international_order?
      return unless afterpay_configuration.present?
      afterpay_country.present?
    end

    def show_on_cart?
      show? && afterpay_settings.display_on_cart?
    end

    def show_on_pdp?
      show? && afterpay_settings.display_on_pdp?
    end


    def installment_price
      order.order_balance / Workarea.config.afterpay[:installment_count]
    end

    def min_price
      return 0.to_m unless afterpay_configuration[:minimumAmount].present?
      afterpay_configuration[:minimumAmount][:amount].to_m
    end

    def max_price
      afterpay_configuration[:maximumAmount][:amount].to_m
    end

    def afterpay_country
      Workarea.config.afterpay[:currency_country_map][currency.to_sym]
    end

    private
      def afterpay_configuration
        options[:afterpay_configuration]
      end

      def order
        @order ||= begin
          o = options[:order]
          Workarea::Storefront::OrderViewModel.new(o)
        end
      end

      def currency
        order.total_price.currency.iso_code
      end

      def afterpay_settings
        @afterpay_settings ||= Workarea::Afterpay::Configuration.current
      end

      # Handles the various International Order plugins Workarea supports
      # This method ensures that the currency the international order is using
      # is supported by afterpay
      def valid_international_order?
        international_currency = order.try(:currency) || currency
        Workarea.config.afterpay[:currency_country_map][international_currency.to_sym].present? && international_currency == currency
      end
    end
  end
end
