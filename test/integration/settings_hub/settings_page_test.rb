# frozen_string_literal: true

require "test_helper"

module SettingsHub
  class SettingsPageTest < ActionDispatch::IntegrationTest
    setup do
      SettingsHub.prepare!
      DummySettings.register
    end

    teardown { SettingsHub.prepare! }

    test "the settings page renders inside the app's own layout" do
      get "/settings_hub"

      assert_select "title", text: "Dummy"
    end

    test "the settings page names itself" do
      get "/settings_hub"

      assert_select "h1", text: "Settings"
    end

    test "the settings page lists a section registered under the user area" do
      SettingsHub.replace_section :profile, area: :user, title: "Profile"

      get "/settings_hub"

      assert_select "nav[aria-label=Settings] a", text: "Profile"
    end

    test "a section the app registers is listed" do
      get "/settings_hub"

      assert_select "nav[aria-label=Settings] a", text: "Notifications"
    end

    test "a section in another area is listed under its own heading" do
      SettingsHub.section :members, area: :team, title: "Team"

      get "/settings_hub"

      assert_select "section[aria-label=Team] a", text: "Team"
    end

    test "the settings page links a section to its own page" do
      get "/settings_hub"

      assert_select "nav[aria-label=Settings] a[href=?]", "/settings_hub/profile"
    end

    test "a section whose capability the person does not hold is not listed" do
      SettingsHub.replace_section :team, area: :team, title: "Team", capability: :manage_team

      get "/settings_hub"

      assert_select "section[aria-label=Team] a", text: "Team", count: 0
    end

    test "a section registered with an address elsewhere links to that address" do
      SettingsHub.replace_section :team, area: :team, title: "Team", at: "/team/members"

      get "/settings_hub"

      assert_select "nav[aria-label=Settings] a[href=?]", "/team/members", text: "Team"
    end

    test "a section that lives on another page is hidden from a person without its capability" do
      SettingsHub.replace_section :team, area: :team, title: "Team", at: "/team/members", capability: :manage_team

      get "/settings_hub"

      assert_select "nav[aria-label=Settings] a", text: "Team", count: 0
    end

    test "a person who is not signed in gets the app's own answer" do
      get "/settings_hub", params: { signed_in: "no" }

      assert_redirected_to "/sign_in"
    end
  end
end
