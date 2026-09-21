require "test_helper"

module SettingsHub
  class SectionTest < ActiveSupport::TestCase
    test "a section running one object holds it under the section's own name" do
      section = Section.new(key: :profile, area: :user, title: "Profile", runs: "SettingsHub::ChangeName")

      assert_equal [ :profile ], section.actions.keys
    end
  end
end
