module PubSub
  class EventWithType < RailsEventStore::Event
    def initialize(event_id: SecureRandom.uuid, metadata: nil, data: {})
      super(
        event_id:,
        metadata:,
        data: "#{self.class.name}Struct".constantize.new(
          data.deep_symbolize_keys
        ).attributes
      )
    end

    def stream_names
      []
    end
  end
end
