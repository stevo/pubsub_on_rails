require 'pub_sub/subscriptions_linter'
require 'pub_sub/event_handler_builder'

module PubSub
  class SubscriptionsList
    include Singleton

    cattr_accessor :config_path
    self.config_path = 'config/subscriptions.yml'

    def self.load!(event_store)
      instance.event_store = event_store
      instance.load!
    end

    def self.lint!
      instance.lint!
    end

    attr_accessor :event_store

    def load!
      domain_subscriptions.each do |domain_name, subscriptions|
        subscriptions.each do |event_name, subscription_type|
          if event_name == 'all_events'
            subscribe_to_all_events(domain_name, subscription_type)
          else
            subscribe_to_event(domain_name, event_name, subscription_type)
          end
        end
      end
    end

    def lint!
      SubscriptionsLinter.new(domain_subscriptions).lint!
    end

    def initialize
      @domain_subscriptions = YAML.load_file(self.class.config_path)
    end

    private

    attr_reader :domain_subscriptions

    def subscribe_to_all_events(domain_name, subscription_type)
      handler_class = "#{domain_name.camelize}Handler".constantize
      event_store.subscribe_to_all_events(
        EventHandlerBuilder.new(handler_class, subscription_type)
      )
    end

    def subscribe_to_event(domain_name, event_name, subscription_type)
      event_domain, name = event_name.split('__').map(&:camelize)
      event_class = "PubSub::#{event_domain}::#{name}Event".constantize
      handler_class = "#{domain_name.camelize}::#{event_domain}#{name}Handler".constantize
      event_store.subscribe(
        EventHandlerBuilder.new(handler_class, subscription_type), to: [event_class]
      )
    end
  end
end
