module Workarea
  module Afterpay
    class Response
      def initialize(response)
        @response = response
      end

      def success?
        @response.present? && (@response.status == 201 || @response.status == 200)
      end

      def body
        return {} unless @response.body.present? && @response.body != "null"
        JSON.parse(@response.body)
      end

      def status
        @response.status
      end
    end
  end
end
