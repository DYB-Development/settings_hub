module SettingsHub
  module Api
    class SectionsController < SettingsHub::ApplicationController
      before_action :refuse_without_capability, only: :update

      def index
        render json: available_sections.map { |section| { key: section.key, actions: section.actions.keys } }
      end

      def update
        return head :unprocessable_content unless requested_action

        result = requested_action.new(person: current_person, account: account_settings_act_on, values: submitted_values).call

        render json: { ok: result.ok?, message: result.message }
      end

      private

      def refuse_without_capability
        head :forbidden unless section && allowed?(section)
      end

      def requested_action
        section.actions[params[:action_name].to_sym]
      end

      def section
        SettingsHub.registry.find(params[:key])
      end

      def submitted_values
        params.except(:controller, :action, :key, :action_name).permit!.to_h.symbolize_keys
      end

      def available_sections
        visible_areas.values.flatten
      end
    end
  end
end
