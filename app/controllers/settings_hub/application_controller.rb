module SettingsHub
  class ApplicationController < ::ApplicationController
    helper KeystoneUiHelper, SettingsHub::Engine.routes.url_helpers, SettingsHub::AppRoutesHelper

    before_action { SettingsHub::AppRoutesHelper.define_app_route_helpers }

    private

    def account_settings_act_on
      SettingsAccount.of(self)
    end

    def visible_areas
      SettingsHub.registry.areas
        .transform_values { |sections| sections.select { |section| allowed?(section) } }
        .reject { |_area, sections| sections.empty? }
    end

    def allowed?(section)
      section.capability.nil? || can?(section.capability)
    end
  end
end
