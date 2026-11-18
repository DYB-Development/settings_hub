module SettingsHub
  module ApplicationHelper
    def settings_in_native_app?
      request.user_agent.to_s.include?("Hotwire Native")
    end
  end
end
