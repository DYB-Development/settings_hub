require "rails/generators"

module SettingsHub
  module Generators
    class SectionGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      INITIALIZER = "config/initializers/settings_hub.rb".freeze
      OPENING = "Rails.application.config.to_prepare do\n".freeze

      def register_the_section
        create_file INITIALIZER, "#{OPENING}end\n" unless initializer_exists?
        inject_into_file INITIALIZER, registration, after: OPENING
      end

      def write_the_object
        template "action.rb.tt", "app/models/save_#{file_name}.rb"
      end

      def write_the_partial
        template "partial.html.erb.tt", "app/views/settings/_#{file_name}.html.erb"
      end

      def write_the_test
        template "action_test.rb.tt", "test/models/save_#{file_name}_test.rb"
      end

      private

      def registration
        %(  SettingsHub.section :#{file_name}, area: :user, title: "#{human_name}", renders: "settings/#{file_name}", runs: "#{save_object}"\n)
      end

      def save_object
        "Save#{class_name}"
      end

      def initializer_exists?
        File.exist?(File.join(destination_root, INITIALIZER))
      end
    end
  end
end
