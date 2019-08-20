module Workarea
  class Storefront::AfterpayDialogController < Storefront::ApplicationController
    def show
      render 'show_aus' if params[:location] == 'au'
    end
  end
end
