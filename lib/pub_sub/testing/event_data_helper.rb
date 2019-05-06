module PubSub
  module Testing
    module EventDataHelper
      def event_data_for(event_name, **payload)
        EventClassFactory.
          build(event_name, abstract_event_class: payload.delete(:abstract_event_class)).
          new(payload).
          attributes
      end
    end
  end
end
