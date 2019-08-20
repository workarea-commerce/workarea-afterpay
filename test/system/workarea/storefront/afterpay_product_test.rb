require 'test_helper'

module Workarea
  module Storefront
    class AfterpayProductText < Workarea::SystemTest
      include Storefront::SystemTest

      def test_showing_a_products_afterpay_price
        @product = create_product(
          name: 'Integration Product',
          variants: [{ sku: 'SKU1', regular: 100.to_m }]
        )

        visit storefront.product_path(@product)
        assert(page.has_content?(t('workarea.storefront.products.afterpay', installment_price: '$25.00', installment_count: Workarea.config.afterpay[:installment_count])))
      end

      def test_eneligble_product_total
        @product = create_product(
          name: 'Integration Product',
          variants: [{ sku: 'SKU1', regular: 1.to_m }]
        )

        visit storefront.product_path(@product)
        refute(page.has_content?(t('workarea.storefront.products.afterpay', installment_price: '$0.25', installment_count: Workarea.config.afterpay[:installment_count])))
      end

      def test_global_display_settings
        Workarea::Afterpay::Configuration.create(enabled: false)
        @product = create_product(
          name: 'Integration Product',
          variants: [{ sku: 'SKU1', regular: 100.to_m }]
        )

        visit storefront.product_path(@product)
        refute(page.has_content?(t('workarea.storefront.products.afterpay', installment_price: '$25.00', installment_count: Workarea.config.afterpay[:installment_count])))
      end

      def test_pdp_display_settings
        Workarea::Afterpay::Configuration.create(display_on_pdp: false)
        @product = create_product(
          name: 'Integration Product',
          variants: [{ sku: 'SKU1', regular: 100.to_m }]
        )

        visit storefront.product_path(@product)
        refute(page.has_content?(t('workarea.storefront.products.afterpay', installment_price: '$25.00', installment_count: Workarea.config.afterpay[:installment_count])))
      end
    end
  end
end
