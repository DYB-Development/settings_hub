# frozen_string_literal: true

require "test_helper"

module SettingsHub
  class ProfileSectionTest < ActionDispatch::IntegrationTest
    setup do
      SettingsHub.prepare!
      DummySettings.register
      @person = ::Person.create!(name: "Pretend Person")
    end

    teardown { SettingsHub.prepare! }

    test "the profile section shows the person's current name" do
      get "/settings_hub/profile", params: { signed_in_as: @person.id }

      assert_select "input[name='name'][value=?]", "Pretend Person"
    end

    test "the profile section shows the new name a person submits" do
      patch "/settings_hub/profile", params: { signed_in_as: @person.id, name: "Renamed Person" }

      get "/settings_hub/profile", params: { signed_in_as: @person.id }

      assert_select "input[name='name'][value=?]", "Renamed Person"
    end

    test "a person cannot rename another person by submitting their id" do
      other = ::Person.create!(name: "Other Person")

      patch "/settings_hub/profile?signed_in_as=#{@person.id}", params: { person_id: other.id, name: "Renamed Person" }

      assert_equal "Other Person", other.reload.name
    end

    test "a key no section is registered under is not found" do
      get "/settings_hub/nope", params: { signed_in_as: @person.id }

      assert_response :not_found
    end

    test "submitting to a key no section is registered under is not found" do
      patch "/settings_hub/nope", params: { signed_in_as: @person.id, name: "Renamed Person" }

      assert_response :not_found
    end

    test "opening a section without its capability is refused" do
      SettingsHub.replace_section :team, area: :team, title: "Team", renders: "settings_hub/sections/profile", capability: :manage_team

      get "/settings_hub/team", params: { signed_in_as: @person.id }

      assert_response :forbidden
    end

    test "opening a section lists the sections beside it" do
      get "/settings_hub/profile", params: { signed_in_as: @person.id }

      assert_select "nav[aria-label=Settings] a", text: "Profile"
    end

    test "the section a person opened is marked in the list" do
      get "/settings_hub/profile", params: { signed_in_as: @person.id }

      assert_select "nav[aria-label=Settings] a[aria-current=page]", text: "Profile"
    end

    test "submitting a section the app registered runs the object that section names" do
      patch "/settings_hub/nickname", params: { signed_in_as: @person.id, name: "Renamed Person" }

      assert_equal "Renamed Person of the account settings act on", @person.reload.name
    end

    test "submitting a section that names no object is refused" do
      SettingsHub.replace_section :nickname, area: :user, title: "Nickname", renders: "settings_hub/sections/profile"

      patch "/settings_hub/nickname", params: { signed_in_as: @person.id, name: "Renamed Person" }

      assert_response :unprocessable_content
    end

    test "the app is told after a section's object has run" do
      patch "/settings_hub/nickname", params: { signed_in_as: @person.id, name: "Renamed Person" }

      assert_equal "nickname:#{@person.id}", response.headers["X-Settings-Change"]
    end

    test "the app is not told when the submission was refused" do
      SettingsHub.section :spare, area: :user, title: "Spare", renders: "settings_hub/sections/profile"

      patch "/settings_hub/spare", params: { signed_in_as: @person.id, name: "Renamed Person" }

      assert_nil response.headers["X-Settings-Change"]
    end

    test "a person whose change is refused is shown the reason" do
      patch "/settings_hub/spoken_for", params: { signed_in_as: @person.id, name: "Renamed Person" }

      assert_select "body", text: /That name is spoken for/
    end

    test "a refused change does not tell the app a change was made" do
      patch "/settings_hub/spoken_for", params: { signed_in_as: @person.id, name: "Renamed Person" }

      assert_nil response.headers["X-Settings-Change"]
    end

    test "the profile section shows why a name the record will not take was refused" do
      patch "/settings_hub/profile", params: { signed_in_as: @person.id, name: "" }

      assert_select "body", text: /Name can't be blank/
    end

    test "opening a section that lives on another page goes to that page" do
      SettingsHub.replace_section :team, area: :team, title: "Team", at: "/team/members"

      get "/settings_hub/team", params: { signed_in_as: @person.id }

      assert_redirected_to "/team/members"
    end

    test "submitting to a section that lives on another page is refused" do
      SettingsHub.replace_section :team, area: :team, title: "Team", at: "/team/members"

      patch "/settings_hub/team", params: { signed_in_as: @person.id }

      assert_response :unprocessable_content
    end

    test "a section's template is given the person and where to submit" do
      get "/settings_hub/from_elsewhere", params: { signed_in_as: @person.id, looking_at: "a-person" }

      assert_select "#from-elsewhere", text: "Shown to Pretend Person in the account settings act on, submitting to /settings_hub/from_elsewhere, looking at a-person"
    end

    test "a section with named actions submits each form to its own address" do
      get "/settings_hub/team", params: { signed_in_as: @person.id }

      assert_select "form#invite[action=?]", "/settings_hub/team/invite"
    end

    test "submitting a named action runs the object that action names" do
      patch "/settings_hub/team/invite", params: { signed_in_as: @person.id, email: "pretend@example.com" }

      assert_equal "Pretend Person invited pretend@example.com", @person.reload.name
    end

    test "submitting an action a section does not name is refused" do
      patch "/settings_hub/team/pretend", params: { signed_in_as: @person.id }

      assert_response :unprocessable_content
    end
  end
end
