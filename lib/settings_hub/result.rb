module SettingsHub
  class Result
    attr_reader :message

    def self.ok
      new(ok: true)
    end

    def self.refused(message)
      new(ok: false, message: message)
    end

    def initialize(ok:, message: nil)
      @ok = ok
      @message = message
    end

    def ok?
      @ok
    end
  end
end
