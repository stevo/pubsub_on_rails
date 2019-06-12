module PubSub
  class EventTrace < ActiveSupport::CurrentAttributes
    EVENT_TRACE_UID_REGEX = /^(?<trace_id>\w+)-(?<trigger_id>\w+)-(?<event_id>\w+)$/
    private_constant :EVENT_TRACE_UID_REGEX

    attribute :trace_id
    attribute :last_event_id

    def self.load_from(event_trace_uid)
      match_data = event_trace_uid&.match(EVENT_TRACE_UID_REGEX)

      if match_data
        self.trace_id = match_data['trace_id']
        self.last_event_id = match_data['event_id']
      end
    end
  end
end
