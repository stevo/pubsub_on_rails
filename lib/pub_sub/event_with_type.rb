module PubSub
  class EventWithType < RailsEventStore::Event
    def initialize(event_id: SecureRandom.uuid, metadata: nil, data: {})
      super(
        event_id:,
        metadata:,
        data: self.class.instance_variable_get(:@schema_validator).new(
          data.deep_symbolize_keys
        ).attributes
      )
    end

    def stream_names
      []
    end

    def self.schema(&block)
      instance_variable_set(:@schema_validator, Class.new(Dry::Struct, &block))
    end
  end
end
