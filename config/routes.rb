Workarea::Storefront::Engine.routes.draw do
  get 'afterpay/start' => 'afterpay#start', as: :start_afterpay
  get 'afterpay/complete/' => 'afterpay#complete', as: :complete_afterpay
  get 'afterpay/cancel/' => 'afterpay#cancel', as: :cancel_afterpay
  get 'afterpay_dialog' => 'afterpay_dialog#show', as: :afterpay_dialog
end


Workarea::Admin::Engine.routes.draw do
  scope '(:locale)', constraints: Workarea::I18n.routes_constraint do
    namespace :afterpay do
      resource :configuration, only: [:edit, :update]
    end
  end
end
