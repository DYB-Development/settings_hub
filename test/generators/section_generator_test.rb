require "test_helper"
require "rails/generators/test_case"
require "generators/settings_hub/section/section_generator"

module SettingsHub
  class SectionGeneratorTest < Rails::Generators::TestCase
    tests SettingsHub::Generators::SectionGenerator
    destination File.expand_path("../../tmp/generators", __dir__)
    setup :prepare_destination

    test "it registers the section" do
      run_generator %w[notifications]

      assert_file "config/initializers/settings_hub.rb", /SettingsHub\.section :notifications/
    end

    test "it writes the object a submitted change runs" do
      run_generator %w[notifications]

      assert_file "app/models/save_notifications.rb", /class SaveNotifications/
    end

    test "it writes the partial the section draws" do
      run_generator %w[notifications]

      assert_file "app/views/settings/_notifications.html.erb", /submit_url/
    end

    test "it writes a test for the section" do
      run_generator %w[notifications]

      assert_file "test/models/save_notifications_test.rb", /class SaveNotificationsTest/
    end

    test "the object it writes accepts a submitted change" do
      run_generator %w[notifications]
      load File.join(destination_root, "app/models/save_notifications.rb")

      assert SaveNotifications.new(person: nil, account: nil, values: {}).call.ok?
    end

    test "settings_hub accepts the registration it writes" do
      run_generator %w[reminders]
      load File.join(destination_root, "app/models/save_reminders.rb")
      run_the_registration

      assert SettingsHub.registry.find(:reminders)
    ensure
      SettingsHub.prepare!
    end

    private

    def run_the_registration
      instance_eval(File.read(File.join(destination_root, "config/initializers/settings_hub.rb"))[/^  SettingsHub\.section.*$/])
    end
  end
end
