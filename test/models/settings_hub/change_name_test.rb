# frozen_string_literal: true

require "test_helper"

module SettingsHub
  class ChangeNameTest < ActiveSupport::TestCase
    test "changing a name puts the new name on the person" do
      person = ::Person.create!(name: "Pretend Person")

      ChangeName.new(person: person, account: nil, values: { name: "Renamed Person" }).call

      assert_equal "Renamed Person", person.reload.name
    end
  end
end
