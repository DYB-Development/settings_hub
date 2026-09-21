module SettingsHub
  class SectionsController < ApplicationController
    before_action :set_section
    before_action :refuse_without_capability

    def show
      return redirect_to @section.at if @section.at

      @person = current_person
      @account = account_settings_act_on
      @areas = visible_areas
      @section_addresses = section_addresses
      @selection = selection

      render template: "settings_hub/settings/show"
    end

    def update
      return head :unprocessable_content unless requested_action

      result = requested_action.new(person: current_person, account: account_settings_act_on, values: submitted_values).call
      return show_refusal(result.message) unless result.ok?

      tell_the_app_it_ran

      redirect_to section_path(params[:key])
    end

    private

    def requested_action
      return @section.actions[params[:action_name].to_sym] if params[:action_name]

      @section.action
    end

    def selection
      params.except(:controller, :action, :key, :action_name).permit!.to_h.symbolize_keys
    end

    def section_addresses
      return { submit_url: section_path(@section.key) } unless @section.named_actions?

      { submit_urls: @section.actions.keys.to_h { |name| [ name, section_action_path(@section.key, name) ] } }
    end

    def show_refusal(message)
      @person = current_person
      @account = account_settings_act_on
      @areas = visible_areas
      @section_addresses = section_addresses
      @selection = selection
      @refusal = message

      render template: "settings_hub/settings/show", status: :unprocessable_content
    end

    def tell_the_app_it_ran
      return unless respond_to?(:after_settings_change, true)

      after_settings_change(section: @section, person: current_person)
    end

    def submitted_values
      params.except(:controller, :action, :key, :signed_in_as).permit!.to_h.symbolize_keys
    end

    def set_section
      @section = SettingsHub.registry.find(params[:key])

      raise ActionController::RoutingError, "No settings section named #{params[:key]}" unless @section
    end

    def refuse_without_capability
      head :forbidden unless allowed?(@section)
    end
  end
end
