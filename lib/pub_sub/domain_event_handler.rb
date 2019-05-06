module PubSub
  class DomainEventHandler
    def initialize(*args)
      @event_data_hash = args.extract_options!
    end

    def call
      raise NotImplementedError
    end

    def call!
      call if process_event?
    end

    private

    attr_reader :event_data_hash

    def process_event?
      true
    end

    def event_data
      @event_data ||= OpenStruct.new(event_data_hash)
    end
  end
end
