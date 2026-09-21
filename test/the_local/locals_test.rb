require "test_helper"

class LocalsTest < ActiveSupport::TestCase
  test "settings_hub ships a local for each of info, install and develop" do
    assert_equal %w[settings_hub-develop settings_hub-info settings_hub-install], local_names
  end

  private

  def local_names
    Dir[SettingsHub::Engine.root.join("the_local/agents/*.md")].map { |path| File.basename(path, ".md") }.sort
  end
end
