require 'pub_sub/payload_attribute'

module PubSub
  Error = Class.new(StandardError)
  EventMissing = Class.new(Error)
  EventPayloadArgumentMissing = Class.new(Error)

  class EventEmission
    def initialize(abstract_event_class, event_class, event_name, explicit_payload, context)
      @abstract_event_class = abstract_event_class
      @event_class = event_class
      @event_name = event_name
      @explicit_payload = explicit_payload
      @context = context
    end

    def call
      if event_class.ancestors.include?(PubSub::EventWithType)
        event_store.publish(event, stream_name:)
      else
        raise(EventMissing, event_name)
      end
    end

    private

    attr_reader :abstract_event_class, :event_class, :event_name, :explicit_payload, :context

    def event
      event_class.new(data: full_payload)
    end

    def event_name_includes_domain?
      event_name.to_s.include?('__')
    end

    def stream_name
      return event_name.to_s.downcase if event_name_includes_domain?

      "#{domain}__#{event_name}"
    end

    def domain
      if abstract_event_class
        abstract_event_class.name.deconstantize.underscore
      else
        context.class.name.deconstantize.demodulize.underscore
      end
    end

    def dry_struct_event_class
      @dry_struct_event_class ||= event_class.name.remove('RailsEventStore').constantize
    end

    # rubocop:disable Metrics/MethodLength
    def full_payload
      dry_struct_event_class.attribute_names.each_with_object({}) do |attribute_name, result|
        result[attribute_name] = PayloadAttribute.new(
          attribute_name, explicit_payload, context
        ).get
      rescue PayloadAttribute::CannotEvaluate => e
        next if dry_struct_event_class.schema.key(attribute_name).default?

        raise(
          EventPayloadArgumentMissing,
          "Event [#{dry_struct_event_class.name}] expects [#{attribute_name}] " \
          "payload attribute to be either exposed as [#{e.message}] method in emitting object " \
          'or provided as argument'
        )
      end
    end
    # rubocop:enable Metrics/MethodLength

    def event_store
      Rails.configuration.event_store
    end
  end
end
