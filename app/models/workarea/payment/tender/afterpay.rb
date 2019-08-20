module Workarea
  class Payment
    class Tender
      class Afterpay < Tender
        field :token, type: String
        field :ready_to_capture, type: Boolean, default: false

        def slug
          :afterpay
        end

        def installment_price
          self.amount / Workarea.config.afterpay[:installment_count]
        end
      end
    end
  end
end
