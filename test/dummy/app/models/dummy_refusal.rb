# frozen_string_literal: true

class DummyRefusal
  def initialize(person:, account:, values:)
    @person = person
    @account = account
    @values = values
  end

  def call
    SettingsHub::Result.refused("That name is spoken for")
  end
end
