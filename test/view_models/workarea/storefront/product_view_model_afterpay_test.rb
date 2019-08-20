require 'test_helper'

module Workarea
  class Storefront::ProductViewModelAfterpayTest < TestCase
    def test_show_afterpay
      settings = Workarea::Afterpay::Configuration.create!

      product = create_product(
        name: 'Test Product',
        variants: [
          { sku: 'SKU', details: { color: 'Pink' }, regular: 100.to_m }
        ]
      )
      vm = Storefront::ProductViewModel.new(product)
      assert(vm.show_afterpay?)


      product = create_product(
        name: 'Test Product',
        variants: [
          { sku: 'SKU', details: { color: 'Pink' }, regular: 1.to_m }
        ]
      )
      vm = Storefront::ProductViewModel.new(product)
      refute(vm.show_afterpay?)

      settings.enabled = false
      settings.save!

      product = create_product(
        name: 'Test Product 3',
        variants: [
          { sku: 'SKU3', details: { color: 'Pink' }, regular: 100.to_m }
        ]
      )
      vm = Storefront::ProductViewModel.new(product)
      refute(vm.show_afterpay?)

      settings.enabled = true
      settings.display_on_pdp = false

      settings.save!

      product = create_product(
        name: 'Test Product 3',
        variants: [
          { sku: 'SKU3', details: { color: 'Pink' }, regular: 100.to_m }
        ]
      )
      vm = Storefront::ProductViewModel.new(product)
      refute(vm.show_afterpay?)
    end

    def test_show_afterpay_returns_false_when_no_pricing
      product = create_product(
        name: 'Test Product',
        variants: [
          { sku: 'SKU', details: { color: 'Pink' } }
        ]
      )

      vm = Storefront::ProductViewModel.new(product)
      refute(vm.show_afterpay?)
    end

    def test_afterpay_installment_price
      product ||= create_product(
        name: 'Test Product',
        variants: [
          { sku: 'SKU', details: { color: 'Pink' }, regular: 100.to_m }
        ]
      )
      vm = Storefront::ProductViewModel.new(product)

      assert_equal(25.00.to_m, vm.installment_price)
    end
  end
end
