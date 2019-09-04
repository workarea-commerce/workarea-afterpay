require 'workarea'
require 'workarea/storefront'
require 'workarea/admin'

require 'workarea/afterpay/engine'
require 'workarea/afterpay/version'

require 'workarea/afterpay/bogus_gateway'
require 'workarea/afterpay/gateway'
require 'workarea/afterpay/response'


require "faraday"

module Workarea
  module Afterpay
    RETRY_ERROR_STATUSES = 500..599

    def self.credentials
      (Rails.application.secrets.afterpay || {}).deep_symbolize_keys
    end

    def self.config
      Workarea.config.afterpay
    end

    def self.merchant_id(location)
      return unless credentials.present?

      country = location.to_sym.downcase

      return unless credentials[country].present?

      credentials[country][:merchant_id]
    end

    def self.secret_key(location)
      return unless credentials.present?

      country = location.to_sym.downcase
      credentials[country][:secret_key]
    end

    def self.test?
      config[:test]
    end

    # Conditionally use the real gateway when secrets are present.
    # Otherwise, use the bogus gateway.
    #
    # @return [Afterpay::Gateway]
    def self.gateway(location, options = {})
      if credentials.present?
        options.merge!(location: location, test: test?)
        Afterpay::Gateway.new(merchant_id(location), secret_key(location), options)
      else
        Afterpay::BogusGateway.new
      end
    end
  end
end
