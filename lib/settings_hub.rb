require "keystone_ui"

require "settings_hub/version"
require "settings_hub/engine"
require "settings_hub/bad_registration"
require "settings_hub/registry"
require "settings_hub/section"
require "settings_hub/result"
require "settings_hub/settings_account"

module SettingsHub
  class << self
    attr_accessor :capabilities
  end

  def self.registry
    @registry ||= Registry.new
  end

  def self.section(key, **details)
    registry.add(Section.new(key: key, **details))
  end

  def self.replace_section(key, **details)
    registry.replace(Section.new(key: key, **details))
  end

  def self.prepare!
    @registry = nil
    register_own_sections
  end

  def self.register_own_sections
    section :profile, area: :user, title: "Profile", renders: "settings_hub/sections/profile", runs: "SettingsHub::ChangeName"
  end
end
