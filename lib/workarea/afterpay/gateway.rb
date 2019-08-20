module Workarea
  module Afterpay
    class Gateway
      attr_reader :merchant_id, :secret_key, :options
      class_attribute :test_rest_endpoint, :production_rest_endpoint


      def initialize(merchant_id, secret_key, options = {})
        @merchant_id = merchant_id
        @secret_key = secret_key
        @options = options
      end

      def get_configuration
        response = connection.get do |req|
          req.url "/v1/configuration"
        end
        Afterpay::Response.new(response)
      end

      def get_order(token)
        response = connection.get do |req|
          req.url "/v1/orders/#{token}"
        end

        Afterpay::Response.new(response)
      end

      def create_order(order)
        response = connection.post do |req|
          req.url "/v1/orders"
          req.body = order.to_json
        end

        Afterpay::Response.new(response)
      end

      def capture(token, order_id)
        body = {
          token: token
        }
        response = connection.post do |req|
          req.url "/v1/payments/capture"
          req.body = body.to_json
        end

        Afterpay::Response.new(response)
      end

      def refund(afterpay_order_id, amount, request_id)
        body = {
          requestId: request_id,
          amount: {
            amount: amount.to_f,
            currency: amount.currency.iso_code
          }
        }

        response = connection.post do |req|
          req.url "/v1/payments/#{afterpay_order_id}/refund"
          req.body = body.to_json
        end
        Afterpay::Response.new(response)
      end

      private

        def connection
          headers = {
            "Content-Type" => "application/json",
            "Accept"       => "application/json",
            "Authorization" => "Basic #{auth_string}",
            "User-Agent" => user_agent
          }

          request_timeouts = {
            timeout: Workarea.config.afterpay[:api_timeout],
            open_timeout: Workarea.config.afterpay[:open_timeout]
          }

          Faraday.new(url: rest_endpoint, headers: headers, request: request_timeouts)
        end

        def auth_string
          @auth_string = Base64.strict_encode64("#{merchant_id}:#{secret_key}")
        end

        def test?
          (options.has_key?(:test) ? options[:test] : true)
        end

        def rest_endpoint
          endpoint_hash = location == :us ? us_endpoints : au_endpoints

          test? ? endpoint_hash[:test_rest_endpoint] : endpoint_hash[:production_rest_endpoint]
        end

        def au_endpoints
          {
            test_rest_endpoint: 'https://api-sandbox.afterpay.com',
            production_rest_endpoint: 'https://api.afterpay.com'
          }
        end

        def us_endpoints
          {
            test_rest_endpoint: 'https://api.us-sandbox.afterpay.com',
            production_rest_endpoint: 'https://api.us.afterpay.com'
          }
        end

        def location
          options[:location]
        end

        def user_agent
          "Afterpay Modile/1.0.0 (WORKAREA/#{Workarea::VERSION::STRING}; Merchant/#{merchant_id}) https://#{Workarea.config.host}"
        end
    end
  end
end
