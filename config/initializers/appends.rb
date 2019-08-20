Workarea::Plugin.append_partials(
  'storefront.product_pricing_details',
  'workarea/storefront/products/afterpay_pricing'
)

Workarea::Plugin.append_partials(
  'storefront.payment_method',
  'workarea/storefront/checkouts/afterpay_payment'
)

Workarea::Plugin.append_partials(
  'storefront.cart_checkout_actions',
  'workarea/storefront/carts/afterpay'
)

Workarea::Plugin.append_javascripts(
  'storefront.config',
  'workarea/storefront/afterpay/config'
)

Workarea::Plugin.append_javascripts(
  'storefront.modules',
  'workarea/storefront/afterpay/modules/afterpay_redirect'
)

Workarea::Plugin.append_stylesheets(
  'storefront.components',
  'workarea/storefront/components/afterpay_dialog'
)

Workarea.append_partials(
  "admin.settings_menu",
  "workarea/admin/shared/afterpay_configuration_link"
)
