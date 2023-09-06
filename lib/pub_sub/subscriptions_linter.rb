module PubSub
  class SubscriptionsLinter
    MissingSubscriptions = Class.new(StandardError)

    def initialize(subscriptions)
      @subscriptions = subscriptions
    end

    def lint!
      raise MissingSubscriptions, error_message if missing_subscriptions.present?
    end

    private

    attr_reader :subscriptions

    def error_message
      "The following subscriptions are missing: \n#{missing_subscriptions.join("\n")}"
    end

    def missing_subscriptions
      (handled_subscription_names - all_subscription_names)
    end

    # :reek:UtilityFunction, :reek:DuplicateMethodCall
    def handled_subscription_names
      Dir[Rails.root.join('app/event_handlers/*/*.rb')].map do |file_path|
        file_path.
          sub(Rails.root.join('app/event_handlers/').to_s, '').
          sub('_handler.rb', '')
      end
    end

    def all_subscription_names
      subscriptions.flat_map do |domain_name, subscriptions|
        subscriptions.keys.map do |event_name|
          "#{domain_name}/#{event_name.sub('__', '_')}"
        end
      end
    end
  end
end
