module PubSub
  class DomainEvent < Dry::Struct
    include Wisper::Publisher

    def broadcast!
      broadcast(event_name, attributes)
    end

    private

    def event_name
      self.class.name.underscore.sub('/', '__').chomp('_event')
    end
  end
end
