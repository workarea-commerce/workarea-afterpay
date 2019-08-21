$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "workarea/afterpay/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "workarea-afterpay"
  s.version     = Workarea::Afterpay::VERSION
  s.authors     = ["Jeff Yucis"]
  s.email       = ["jyucis@workarea.com"]
  s.homepage    = "https://github.com/workarea-commerce/workarea-afterpay"
  s.summary     = "Workarea Commerce Platform Afterpay integration"
  s.description = "Adds Afterpay as a payment method for Workarea Commerce Platform"

  s.files = `git ls-files`.split("\n")

  s.license = 'Business Software License'

  s.add_dependency 'workarea', '~> 3.x'

  s.add_dependency "faraday", "~> 0.10"
end
