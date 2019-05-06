require 'pub_sub/payload_attribute'

module PubSub
  class EventEmission
    EventPayloadArgumentMissing = Class.new(StandardError)

    def initialize(event_class, explicit_payload, context)
      @event_class = event_class
      @explicit_payload = explicit_payload
      @context = context
    end

    def call
      event_class.new(full_payload).broadcast!
    end

    private

    attr_reader :event_class, :explicit_payload, :context

    def event_payload_attribute_names
      event_class.attribute_names
    end

    # rubocop:disable Metrics/MethodLength
    def full_payload
      event_payload_attribute_names.each_with_object({}) do |attribute_name, result|
        result[attribute_name] = PayloadAttribute.new(attribute_name, explicit_payload, context).get
      rescue PayloadAttribute::CannotEvaluate => cannot_evaluate_error
        if event_class.schema[attribute_name.to_sym].default?
          next
        else
          raise(
            EventPayloadArgumentMissing,
            "Event [#{event_class.name}] expects [#{attribute_name}] payload attribute to be" \
              " either exposed as [#{cannot_evaluate_error.message}] method in emitting object" \
              ' or provided as argument'
          )
        end
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
