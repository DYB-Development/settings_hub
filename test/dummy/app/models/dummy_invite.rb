# frozen_string_literal: true

class DummyInvite
  def initialize(person:, account:, values:)
    @person = person
    @account = account
    @values = values
  end

  def call
    @person.update(name: "#{@person.name} invited #{@values[:email]}")

    SettingsHub::Result.ok
  end
end
