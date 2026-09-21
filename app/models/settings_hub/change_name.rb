module SettingsHub
  class ChangeName
    def initialize(person:, account:, values:)
      @person = person
      @account = account
      @values = values
    end

    def call
      return Result.refused(@person.errors.full_messages.to_sentence) unless @person.update(name: @values[:name])

      Result.ok
    end
  end
end
