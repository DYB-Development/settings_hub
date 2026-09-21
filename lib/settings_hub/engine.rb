module SettingsHub
  class Engine < ::Rails::Engine
    isolate_namespace SettingsHub

    config.to_prepare do
      SettingsHub.prepare!
    end
  end
end
