require "test_helper"

class SettingsHubTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert SettingsHub::VERSION
  end

  test "preparing the registrations again, as a code reload does, is not refused" do
    SettingsHub.prepare!

    assert_nothing_raised { SettingsHub.prepare! }
  ensure
    SettingsHub.prepare!
  end

  test "replacing a section puts the new one in the registry" do
    SettingsHub.prepare!
    SettingsHub.replace_section :profile, area: :user, title: "Renamed profile"

    assert_equal "Renamed profile", SettingsHub.registry.find(:profile).title
  ensure
    SettingsHub.prepare!
  end
end
