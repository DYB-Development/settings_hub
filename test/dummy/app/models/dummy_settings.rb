# frozen_string_literal: true

class DummySettings
  def self.register
    SettingsHub.section :notifications, area: :user, title: "Notifications"
    SettingsHub.section :from_elsewhere, area: :user, title: "From elsewhere", renders: "dummy_sections/from_elsewhere"
    SettingsHub.section :spoken_for, area: :user, title: "Spoken for", renders: "settings_hub/sections/profile", runs: "DummyRefusal"
    SettingsHub.section :team, area: :team, title: "Team", renders: "dummy_sections/team", runs: { invite: "DummyInvite", rename: "DummyRename" }
    SettingsHub.section :nickname, area: :user, title: "Nickname", renders: "settings_hub/sections/profile", runs: "DummyRename"
  end
end
