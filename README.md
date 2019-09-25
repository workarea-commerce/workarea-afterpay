Workarea Afterpay
================================================================================

Afterpay is a pay-by-installments solution. If a user selects afterpay as a payment
option they are taken to the afterpay site where they enter their payment details.
After confirming and placing the order the payment is then captured by the Workarea platform.

Both the US and Australian API endpoints are supported in this implementation. See the **Secrets** section for setting up credentials.
An orders currency code will determine what API endpoints will be used when placing an order. Orders in a non supported currency will not
have Afterpay as an option when checking out.

Refunds are supported in the Workarea Platform.

Workarea Afterpay orders use the following flow:

1. An API call is made on the Checkout Payment step to see if the order is eligible for Afterpay.
2. If eligible an option for Afterpay is displayed.
3. User clicks place order button - an api call is made to get a token.
4. If token creation is successful the token is injected into the DOM and the user is redirected to the Afterpay site.
5. User enters payment details and submits payment.
6. User is taken back to Workarea and payment is captured.
7. Order confirmation page is displayed.

A diagram of the flow can be found here: https://docs.afterpay.com/us-online-api-v1.html#direct-payment-flow

Implementation Notes
--------------------------------------------------------------------------------

**Payment**

Afterpay requires that all payments are captured when the order is placed. All Afterpay
payments will perform a "Purchase" action instead of the default "Authorize"; meaning that Afterpay payments will be "captured" immediately. Other payment tenders will still behave as configured.


**Product Detail Pages**

This integration makes use of the ```storefront.product_pricing_details``` append point to display the Afterpay pricing on the product detail page. Some custom PDP templates may not have this append point.

If you wish for the Afterpay pricing to appear on your custom PDP template simply add the append point manually by adding the following:

```ruby
= append_partials('storefront.product_pricing_details', product: product)
```


**Testing**

The test API endpoints will be used by default. Production mode can be triggered by setting the ***test*** configuration value in an initializer to ***false***.

```ruby
config.afterpay.test = false
```


**Proxy**

Be sure to whitelist the sandbox and production API endpoints to the Proxy in your hosting environment. Workarea environments running Kubernetes can add this via the command line interface tool.


**Certification Process**

Afterpay has a rigorous certification process that must be completed before using Afterpay in a production environment. This plugin can not guarantee compliance with this process because most of the certification process is branding and marketing specific and is beyond the scope of this integration.

Configuration
--------------------------------------------------------------------------------
The display of Afterpay can be controlled via the ***Afterpay Configuration*** control panel in the Workarea Admin.

The following can be controlled
- Global Display: Turn on/off the display on the entire site, including checkout.
- PDP Display: Turn on/off display on the product detail page.
- Cart Display: Turn on/off display on the cart page


Secrets
--------------------------------------------------------------------------------

The regional US and Australian API endpoints require separate credentials. You can omit regions that are not relevant to your business needs.

    afterpay:
      us:
        merchant_id: YOUR_US_MERCHANT_ID
        secret_key: YOUR_US_SECRET_KEY
      au:
        merchant_id: YOUR_AU_MERCHANT_ID
        secret_key: YOUR_AU_SECRET_KEY


Getting Started
--------------------------------------------------------------------------------

Add the gem to your application's Gemfile:

```ruby
# ...
gem 'workarea-afterpay'
# ...
```

Update your application's bundle.

```bash
cd path/to/application
bundle
```

Workarea Commerce Documentation
--------------------------------------------------------------------------------

See [https://developer.workarea.com](https://developer.workarea.com) for Workarea Commerce documentation.

License
--------------------------------------------------------------------------------

Workarea Afterpay is released under the [Business Software License](LICENSE)
