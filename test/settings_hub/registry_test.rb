require "test_helper"

module SettingsHub
  class RegistryTest < ActiveSupport::TestCase
    test "a different section claiming a key already taken in its area is refused" do
      registry = Registry.new
      registry.add(Section.new(key: :profile, area: :user, title: "Profile"))

      assert_raises(BadRegistration) do
        registry.add(Section.new(key: :profile, area: :user, title: "Something else"))
      end
    end

    test "the refusal for a key already taken names the key" do
      registry = Registry.new
      registry.add(Section.new(key: :profile, area: :user, title: "Profile"))

      refusal = assert_raises(BadRegistration) do
        registry.add(Section.new(key: :profile, area: :user, title: "Something else"))
      end

      assert_match "profile", refusal.message
    end

    test "a section running an object the app cannot find is refused" do
      registry = Registry.new

      assert_raises(BadRegistration) do
        registry.add(Section.new(key: :profile, area: :user, title: "Profile", runs: "NoSuchObject"))
      end
    end

    test "a section naming a capability the app does not recognise is refused" do
      registry = Registry.new(capabilities: [ :manage_team ])

      assert_raises(BadRegistration) do
        registry.add(Section.new(key: :team, area: :team, title: "Team", capability: :mange_team))
      end
    end

    test "the refusal for an unrecognised capability names the capability" do
      registry = Registry.new(capabilities: [ :manage_team ])

      refusal = assert_raises(BadRegistration) do
        registry.add(Section.new(key: :team, area: :team, title: "Team", capability: :mange_team))
      end

      assert_match "mange_team", refusal.message
    end

    test "a replacement running an object the app cannot find is refused" do
      registry = Registry.new

      assert_raises(BadRegistration) do
        registry.replace(Section.new(key: :profile, area: :user, title: "Profile", runs: "NoSuchObject"))
      end
    end

    test "a section that says it replaces the one already registered takes its place" do
      registry = Registry.new
      registry.add(Section.new(key: :profile, area: :user, title: "Profile"))

      registry.replace(Section.new(key: :profile, area: :user, title: "Something else"))

      assert_equal "Something else", registry.find(:profile).title
    end
  end
end
