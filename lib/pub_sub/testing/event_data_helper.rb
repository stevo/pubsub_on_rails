module PubSub
  module Testing
    module EventDataHelper
      def event_data_for(event_name, **payload)
        event_class = PubSub::EventClassFactory.build(
          event_name, abstract_event_class: payload.delete(:abstract_event_class)
        )

        if event_class.ancestors.include?(PubSub::EventWithType)
          event_class.new(data: payload)
        else
          event_class.new(payload).attributes
        end
      end
    end
  end
end
