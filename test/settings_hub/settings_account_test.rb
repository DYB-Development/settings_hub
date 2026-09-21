require "test_helper"

module SettingsHub
  class SettingsAccountTest < ActiveSupport::TestCase
    class AppThatSaysWhichAccount
      def settings_account
        "the account settings act on"
      end

      def current_account
        "the account they switched to"
      end
    end

    class AppThatOnlySaysWhereTheyAre
      def current_account
        "the account they switched to"
      end
    end

    class AppThatSaysNeither
    end

    test "an app that says neither gets no account" do
      assert_nil SettingsAccount.of(AppThatSaysNeither.new)
    end

    test "an app that says only where they are gets that account" do
      assert_equal "the account they switched to", SettingsAccount.of(AppThatOnlySaysWhereTheyAre.new)
    end

    test "an app that says which account settings act on is taken at its word" do
      assert_equal "the account settings act on", SettingsAccount.of(AppThatSaysWhichAccount.new)
    end
  end
end
