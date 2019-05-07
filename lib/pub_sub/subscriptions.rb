require 'pub_sub/linter'

module PubSub
  mattr_accessor :subscriptions

  class Subscriptions
    include Singleton

    cattr_accessor :subscriptions_path
    self.subscriptions_path = 'config/subscriptions.yml'

    def self.load!
      PubSub.subscriptions = Subscriptions.instance
      PubSub.subscriptions.register(:all)
    end

    def self.lint!
      instance.lint!
    end

    def lint!
      Linter.new(config).lint!
    end

    def initialize
      @config = YAML.load_file(self.class.subscriptions_path)
    end

    def register(scope = :all)
      (scope == :all ? config : config.slice(scope.to_s)).each do |domain_name, subscriptions|
        subscriptions.each do |event_name, subscription_type|
          options = {}
          options[:on] = event_name unless event_name == 'all_events'
          options[:broadcaster] = subscription_type == 'sync' ? :default : subscription_type.to_sym

          Wisper.subscribe("::#{domain_name.camelize}".constantize, options)
        end
      end
    end

    def clear!
      Wisper.clear
    end

    private

    attr_reader :config
  end
end
