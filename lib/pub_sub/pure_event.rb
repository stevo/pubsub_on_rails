module PubSub
  class PureEvent < Dry::Struct
    include Wisper::Publisher

    def broadcast!
      broadcast(event_name, attributes_to_broadcast)
    end

    private

    def attributes_to_broadcast
      attributes
    end

    def event_name
      self.class.name.underscore.sub('/', '__').chomp('_event')
    end
  end
end
