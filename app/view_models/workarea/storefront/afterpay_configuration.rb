module Workarea
  module Storefront
    module AfterpayConfiguration
      class AfterpayConfigurationError < StandardError; end
      # get the configuration for afterpay
      # this will be used to determine elgibility
      # for displaying the afterpay payment option
      def afterpay_configuration(location)
        merchant_id = Workarea::Afterpay.merchant_id(location)
        key = "afterpay_configuration/#{merchant_id}"
        afterpay_configuration = begin
          Rails.cache.fetch(key, expires_in: Workarea.config.cache_expirations.afterpay_configuration) do
            gateway = Workarea::Afterpay.gateway(location)
            response = gateway.get_configuration
            raise AfterpayConfigurationError unless response.success?
            response.body
          end
        end
      rescue
        # avoids caching a failed API response
        nil
      end
    end
  end
end
