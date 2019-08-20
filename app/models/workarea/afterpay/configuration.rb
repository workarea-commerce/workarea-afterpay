module Workarea
  module Afterpay
    class Configuration
      include ApplicationDocument

      field :enabled, type: Boolean, default: true

      field :display_on_cart, type: Boolean, default: true
      field :display_on_pdp, type: Boolean, default: true

      def self.current
        Workarea::Afterpay::Configuration.first || Workarea::Afterpay::Configuration.new
      end
    end
  end
end
