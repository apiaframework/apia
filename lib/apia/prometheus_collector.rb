# frozen_string_literal: true

unless defined?(Yabeda)
  raise 'Yabeda is not defined. Please add the `yabeda` and `yabeda-rails` gems to your Gemfile.'
end

module Apia
  class PrometheusCollector

    def register_metrics
      Yabeda.configure do
        group :apia do
          counter :requests_total do
            comment 'The total number of requests handled by Apia'
            tags([:method, :route, :status, :api, :endpoint, :authenticator, :error_code])
          end
          histogram :endpoint_duration do
            comment 'Time spent in Apia requests in seconds'
            unit :seconds
            tags([:status, :endpoint])
            buckets Yabeda::Rails::LONG_RUNNING_REQUEST_BUCKETS
          end
        end
      end
    end

    def start
      register_metrics
      ActiveSupport::Notifications.subscribe(/(request(_error)?)\.apia/) do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)

        increment_request_total_metric(event)
        observe_endpoint_duration_metric(event)
      end
    end

    private

    def increment_request_total_metric(event)
      tags = {
        endpoint: event.payload[:request]&.endpoint&.name,
        status: event.payload[:response]&.status,
        api: event.payload[:request]&.api&.name,
        route: "/#{event.payload[:request]&.route&.path}",
        method: event.payload[:request]&.route&.request_method,
        authenticator: event.payload[:request]&.authenticator&.name,
        error_code: extract_error_code_from_response_body(event.payload[:response]&.body)
      }
      Yabeda.apia.requests_total.increment(tags, by: 1)
    end

    def observe_endpoint_duration_metric(event)
      return if event.payload[:time].nil?

      tags = {
        endpoint: event.payload[:request]&.endpoint&.name,
        status: event.payload[:response]&.status
      }
      Yabeda.apia.endpoint_duration.measure(tags, event.payload[:time])
    end

    def extract_error_code_from_response_body(body)
      return '' unless body.is_a?(Hash)

      body.dig(:error, :code).to_s
    end

  end
end

collector = Apia::PrometheusCollector.new
collector.start
