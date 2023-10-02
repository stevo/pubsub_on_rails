module PubSub
  class DomainEventHandler
    def initialize(event)
      @event = event
    end

    def call
      raise NotImplementedError
    end

    def call!
      call if process_event?
    end

    private

    attr_reader :event

    def process_event?
      true
    end

    def event_data
      @event_data ||= OpenStruct.new(event_data_hash)
    end

    def event_data_hash
      event.data
    end
  end
end
