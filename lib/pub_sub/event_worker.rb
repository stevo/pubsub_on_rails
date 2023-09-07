module PubSub
  class EventWorker
    include Sidekiq::Job

    def perform(class_name, event_id)
      class_name.constantize.new(
        event_store.read.event(event_id)
      ).call!
    end

    private

    def event_store
      Rails.configuration.event_store
    end
  end
end
