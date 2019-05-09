require 'pub_sub/pure_event'

module PubSub
  class DomainEvent < PureEvent
    attribute :event_trace_id, Types::Strict::String.default {
      EventTrace.trace_id ||= SecureRandom.hex(8)
    }
    attribute :event_id, Types::Strict::String.default {
      SecureRandom.hex(8)
    }
    attribute :trigger_id, Types::Strict::String.default {
      EventTrace.last_event_id || 'ORIGIN'
    }

    def initialize(*args)
      super(*args)
      EventTrace.last_event_id = event_id
    end

    private

    def attributes_to_broadcast
      super.
        except(:event_trace_id, :event_id, :trigger_id).
        merge(event_uid: "#{event_trace_id}-#{trigger_id}-#{event_id}")
    end
  end
end
