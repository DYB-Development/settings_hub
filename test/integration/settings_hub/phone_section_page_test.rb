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

    test "on a phone a section page hides the Settings heading so the section's own name is its title" do
      get "/settings_hub/profile", params: { signed_in_as: @person.id }

      assert_select "[class~='hidden'][class~='lg:block'] h1", text: "Settings"
    end

    test "inside the native app a section page draws no web back link, leaving the app's own back button" do
      get "/settings_hub/profile", params: { signed_in_as: @person.id }, headers: { "User-Agent" => "Hotwire Native iOS; Turbo Native iOS" }

      assert_select "a[aria-label=Back]", count: 0
    end

    test "on desktop a section page shows the list of sections beside the section, marking the section as current" do
      get "/settings_hub/profile", params: { signed_in_as: @person.id }

      assert_select "[class~='lg:block'] nav[aria-label=Settings] a[aria-current=page]", text: "Profile"
    end

    test "a refused save on a phone shows the refusal on the section's own page, with its back link" do
      patch "/settings_hub/spoken_for", params: { signed_in_as: @person.id, name: "Renamed Person" }

      assert_select "[class~='lg:hidden'] a[aria-label=Back][href='/settings_hub/']"
    end
  end
end
