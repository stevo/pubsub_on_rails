module PubSub
  module Testing
    module RailsEventStore
      def event_store
        Rails.configuration.event_store
      end
    end
  end
end
