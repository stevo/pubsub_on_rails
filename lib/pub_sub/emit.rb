require 'pub_sub/event_class_factory'
require 'pub_sub/event_emission'

module PubSub
  module Emit
    def emit(event_name, explicit_payload = {})
      abstract_event_class = explicit_payload.delete(:abstract_event_class)
      event_class = EventClassFactory.build(
        event_name,
        domain_name: self.class.name.deconstantize.demodulize,
        abstract_event_class:
      )

      EventEmission.new(abstract_event_class, event_class, event_name, explicit_payload, self).call
    end
  end
end
