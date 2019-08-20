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
        @body ||= JSON.parse(@response.body)
      end
    end
  end
end
