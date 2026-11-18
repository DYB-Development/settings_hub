# frozen_string_literal: true

require "test_helper"

module SettingsHub
  class PhoneSectionPageTest < ActionDispatch::IntegrationTest
    setup do
      SettingsHub.prepare!
      DummySettings.register
      @person = ::Person.create!(name: "Pretend Person")
    end

    teardown { SettingsHub.prepare! }

    test "on a phone a section page has a back link to the settings page" do
      get "/settings_hub/profile", params: { signed_in_as: @person.id }

      assert_select "[class~='lg:hidden'] a[aria-label=Back][href='/settings_hub/']"
    end
  end
end
