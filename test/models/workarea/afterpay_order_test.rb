require 'test_helper'

module Workarea
  class AfterpayOrderTest < Workarea::TestCase
    def test_afterpay_location
      order = create_order
      assert_equal(:us, order.afterpay_location)
    end
  end
end
