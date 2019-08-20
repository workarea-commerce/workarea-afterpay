module Workarea
  module Admin
    module Afterpay
      class ConfigurationsController < Admin::ApplicationController
        required_permissions :settings

        def edit
          @configuration = configuration
        end

        def update
          if configuration.update_attributes(configuration_params)
            redirect_to admin.edit_afterpay_configuration_path, flash: { success: t('workarea.admin.afterpay_configuration.edit.flash_messages.updated') }
          else
            flash[:error] = t('workarea.admin.afterpay_configuration.edit.flash_messages.save_error')
            @configuration = configuration
            render :edit, status: :unprocessable_entity
          end
        end

        private
          def configuration
            model = Workarea::Afterpay::Configuration.current
            Workarea::Admin::AfterpayConfigurationViewModel.new(model)
          end

          def configuration_params
            params.permit(:enabled, :display_on_cart, :display_on_pdp)
          end
      end
    end
  end
end
