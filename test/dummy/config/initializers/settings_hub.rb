# frozen_string_literal: true

Rails.application.config.to_prepare do
  DummySettings.register
end
