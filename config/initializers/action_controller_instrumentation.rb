# frozen_string_literal: true
ActionController::Instrumentation.class_eval do
  def process_action(*args)
    raw_payload = {
      controller: self.class.name,
      action: self.action_name,
      params: request.filtered_parameters,
      format: request.format.try(:ref),
      method: request.request_method,
      path: (request.fullpath rescue 'unknown')
    }

    ActiveSupport::Notifications.instrument('start_processing.action_controller', raw_payload.dup)

    ActiveSupport::Notifications.instrument('process_action.action_controller', raw_payload) do |payload|
      begin
        result = super
        payload[:status] = response.status
        payload[:session_id] = self.session_id unless self.session_id.nil?
        result
      ensure
        append_info_to_payload(payload)
      end
    end
  end
end
