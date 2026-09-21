module SettingsHub
  module SettingsAccount
    def self.of(controller)
      return controller.send(:settings_account) if controller.respond_to?(:settings_account, true)
      return controller.send(:current_account) if controller.respond_to?(:current_account, true)

      nil
    end
  end
end
