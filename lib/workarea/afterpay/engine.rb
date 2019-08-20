require 'workarea/afterpay'

module Workarea
  module Afterpay
    class Engine < ::Rails::Engine
      include Workarea::Plugin
      isolate_namespace Workarea::Afterpay

      config.to_prepare do
        Storefront::ApplicationController.helper(Storefront::AfterpayHelper)
      end
    end
  end
end
