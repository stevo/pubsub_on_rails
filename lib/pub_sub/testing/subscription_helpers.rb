module PubSub
  module Testing
    module SubscriptionsHelper
      def with_subscription_to(*domains)
        domains.each do |domain|
          PubSub.subscriptions.register(domain)
        end
        yield
        clear_wisper_subscriptions!
      end

      def subscribe_logger!
        PubSub.subscriptions.register(:logging)
      end
      module_function :subscribe_logger!

      def clear_wisper_subscriptions!
        PubSub.subscriptions.clear!
        subscribe_logger!
      end
      module_function :clear_wisper_subscriptions!
    end
  end
end
