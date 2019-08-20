require 'workarea/testing/teaspoon'

Teaspoon.configure do |config|
  config.root = Workarea::Afterpay::Engine.root
  Workarea::Teaspoon.apply(config)
end
