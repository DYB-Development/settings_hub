require "test_helper"

module SettingsHub
  class ApiSectionsTest < ActionDispatch::IntegrationTest
    setup do
      SettingsHub.prepare!
      DummySettings.register
      @person = ::Person.create!(name: "Pretend Person")
    end

    teardown { SettingsHub.prepare! }

    test "a caller asks for the sections available to it" do
      get "/settings_hub/api/sections", params: { signed_in_as: @person.id }

      assert_includes JSON.parse(response.body).map { |section| section["key"] }, "profile"
    end

    test "a caller is not given a section the person may not see" do
      SettingsHub.replace_section :team, area: :team, title: "Team", capability: :manage_team

      get "/settings_hub/api/sections", params: { signed_in_as: @person.id }

      assert_not_includes JSON.parse(response.body).map { |section| section["key"] }, "team"
    end

    test "a section names the actions it offers" do
      get "/settings_hub/api/sections", params: { signed_in_as: @person.id }

      assert_equal %w[invite rename], section_named("team")["actions"]
    end

    test "a caller runs an action and is told it succeeded" do
      patch "/settings_hub/api/sections/nickname/nickname", params: { signed_in_as: @person.id, name: "Renamed Person" }

      assert JSON.parse(response.body)["ok"]
    end

    test "a caller whose change is refused is told why" do
      patch "/settings_hub/api/sections/spoken_for/spoken_for", params: { signed_in_as: @person.id, name: "Taken" }

      assert_equal "That name is spoken for", JSON.parse(response.body)["message"]
    end

    test "a refused change saves nothing" do
      patch "/settings_hub/api/sections/spoken_for/spoken_for", params: { signed_in_as: @person.id, name: "Taken" }

      assert_equal "Pretend Person", @person.reload.name
    end

    test "a caller is refused a section the person may not see" do
      SettingsHub.replace_section :team, area: :team, title: "Team", capability: :manage_team,
        runs: { invite: "DummyInvite" }

      patch "/settings_hub/api/sections/team/invite", params: { signed_in_as: @person.id }

      assert_response :forbidden
    end

    test "the JSON path draws no page" do
      get "/settings_hub/api/sections", params: { signed_in_as: @person.id }

      assert_equal "application/json", response.media_type
    end

    test "a caller naming an action the section does not offer is refused" do
      patch "/settings_hub/api/sections/nickname/not_an_action", params: { signed_in_as: @person.id }

      assert_response :unprocessable_content
    end

    private

    def section_named(key)
      JSON.parse(response.body).find { |section| section["key"] == key }
    end
  end
end
