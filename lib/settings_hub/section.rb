module SettingsHub
  class Section
    attr_reader :key, :area, :title, :renders, :capability, :runs, :at

    def initialize(key:, area:, title:, renders: nil, capability: nil, runs: nil, at: nil)
      @key = key.to_sym
      @area = area.to_sym
      @title = title
      @renders = renders
      @capability = capability
      @runs = runs
      @at = at
    end

    def action
      actions[key]
    end

    def actions
      return {} if runs.nil?
      return { key => runs.constantize } unless runs.is_a?(Hash)

      runs.transform_values(&:constantize)
    end

    def named_actions?
      runs.is_a?(Hash)
    end
  end
end
