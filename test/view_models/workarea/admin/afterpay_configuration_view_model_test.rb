require 'test_helper'

module Workarea
  module Admin
    class AfterpayConfigurationViewModelTest < TestCase
      def test_limits
        Workarea::Afterpay
          .stubs(:credentials)
          .returns(us: { merchant_id: 'foo' }, au: { merchant_id: 'bar' })

        model = Workarea::Afterpay::Configuration.current
        view_model = AfterpayConfigurationViewModel.new(model)

        assert_equal({ min: 0.to_m, max: nil }, view_model.au_limits)
        assert_equal({ min: 0.to_m, max: nil }, view_model.us_limits)
      end
    end
  end
end
