module PubSub
  class EventHandlerBuilder
    def initialize(class_name, subscription_type)
      @class_name = class_name
      @subscription_type = subscription_type.to_sym
    end

    def call(event)
      if async?
        EventWorker.perform_async(class_name.to_s, event.event_id)
      else
        class_name.new(event).call!
      end
    end

    protected

    attr_reader :class_name, :subscription_type

    def ==(other)
      class_name == other.class_name && subscription_type == other.subscription_type
    end

    private

    def async?
      subscription_type == :async
    end
  end
end
