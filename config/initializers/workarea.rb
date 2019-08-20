Workarea.configure do |config|
  config.cache_expirations.afterpay_configuration = 1.hour

  config.tender_types.append(:afterpay)

  config.afterpay = ActiveSupport::Configurable::Configuration.new
  config.afterpay.api_timeout = 5
  config.afterpay.open_timeout = 2
  config.afterpay.installment_count = 4

  config.afterpay.test = !Rails.env.production?

  config.afterpay.currency_country_map = {
      "USD": "US",
      "AUD": "AU"
  }
end
