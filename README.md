# PubSub on Rails

PubSub on Rails is a gem facilitating opinionated approach to leveraging publish/subscribe messaging pattern in Ruby on Rails applications.

There are many programming techniques that are powerful yet complex. The beauty of publish/subscribe patterns is that it is powerful while staying simple.

Instead of using callbacks or directly and explicitly executing series of actions, action execution is requested using an event object combined with event subscription.
This helps in keeping code isolation high, and therefore makes large codebases maintainable and testable.

While it has little to do with event sourcing, it encompasses a couple of ideas related to domain-driven development.
Therefore it is only useful in applications in which domains/bounded-contexts can be identified.
This is especially true for applications covering many side effects, integrations and complex business logic.

## Entities

There are five entities that are core to PubSub on Rails: domains, events, event publishers, event handlers and subscriptions.

### Domain

Domain is simply a named context in application. You can refer to it as "module", "subsystem", "engine", whatever you like.
Good names for domains are "ordering", "messaging", "logging", "accounts", "logistics" etc.
Your app does not need to have code isolated inside domains, but using Component-Based Rails Applications concept (CBRA) sounds like a nice idea to be combined with PubSub on Rails.

Domain example:

```ruby
# app/domains/messaging.rb

module Messaging
  extend PubSub::Domain
end
```

### Event

Event is basically an object indicating that something has happened (event has occured).
There are two important things that need to be considered when planning an event: its **name** and its **payload** (fields).
Both are quite easy to change / extend later, but it might become a chore in the long run.

Name of event should describe an action that has just happened, also it should be namespaced with the name of the domain it has occurred within.
Some examples of good event names: `Ordering::OrderCancelled`, `Messaging::IncorrectLoginNotificationSent`, `Accounts::UserCreated`, `Bookings::CheckinDateChanged`, `Reporting::MonthlySalesReportGenerationRequested`

Payload of event is just simple set of fields that should convey critical information related to the event.
As the payload is critical for each event, PubSub on Rails leverages `Dry::Struct` and `Dry::Types` to ensure both presence and correct type of attributes events are created with.
It is a good rule of a thumb not to create too many fields for each event and just start with the minimal set. It is easy to add more fields to event's payload later (while it might be cumbersome to remove or change them).

Event example:

```ruby
# app/events/ordering/order_created_event.rb

module Ordering
  class OrderCreatedEvent < PubSub::DomainEvent
    attribute :order_id, Types::Strict::Integer
    attribute :customer_id, Types::Strict::Integer
    attribute :line_items, Types::Strict::Array
    attribute :total_amount, Types::Strict::Float
    attribute :comment, Types::Strict::String.optional
  end
end
```

### Event publisher

Event publisher is any class capable of emitting an event.
Usually a great places to start emitting events are model callbacks, service objects or event handlers.
It is very preferable to emit one specific event from only one place, as in most cases this is makes the most sense and makes the whole solution more comprehensible.

Event publisher example:

```ruby
# app/models/order.rb

class Order < ApplicationRecord
  include PubSub::Emit

  belongs_to :customer
  has_many :line_items

  #...

  after_create do
    emit(:ordering__guest_checked_in, order_id: id)
  end
end
```

### Event handler

Event handler is a class that encapsulates logic that should be executed in reaction to event being emitted.
One event can be handled by many handlers, but only one unique handler within each domain.
Event handlers can be executed synchronously or asynchronously. The latter is recommended for both performance and error-recovery reasons.

Event handler example:

```ruby
# app/event_handlers/messaging/ordering_order_created_handler.rb

module Messaging
  class OrderingOrderCreatedHandler < PubSub::DomainEventHandler
    def call
      OrderMailer.order_creation_notification(order).deliver_now
    end

    private

    def order
      Order.find(event_data.order_id)
    end
  end
end
```

### Subscription

Subscription is "the glue", the binds events with their corresponding handlers.
Each subscription binds one or all events with one handler.
Subscription defines if given handler should be executed in synchronous or asynchronous way.

Subscription example:

```yaml
messaging:
  ordering__order_created: async
```

## Testing

Most of entities in Pub/Sub approach should be tested, yet both domain and event classes can be tested implicitly.
It is recommended to start testing from testing subscription itself, then ensure that both event emission and handling are in place. Depending on situation the recommended order may change though.

### RSpec

The recommended RSpec configuration is as follows:

```ruby
# spec/support/pub_sub.rb
 
require 'pub_sub/testing'

RSpec.configure do |config|
  config.include Wisper::RSpec::BroadcastMatcher
  config.include PubSub::Testing::SubscriptionsHelper
  config.include PubSub::Testing::EventDataHelper

  config.before(:suite) do
    PubSub::Testing::SubscriptionsHelper.clear_wisper_subscriptions!
  end

  config.around(:each, subscribers: true) do |example|
    domain_name = example.metadata[:described_class].to_s.underscore
    PubSub.subscriptions.register(domain_name)
    example.run
    clear_wisper_subscriptions!
  end
end
```

### Testing subscription

Testing subscription is as easy as telling what domains should subscribe to what event in what way.

Example:

```ruby
RSpec.describe Messaging, subscribers: true do
  it { is_expected.to subscribe_to(:ordering__order_created).asynchronously }
end
```

### Testing publishers

To test publisher it is crucial to test if event was emitted (broadcasted) under certain conditions (if any).

Example:

```ruby
RSpec.describe Order do
  describe 'after_create' do
    it 'emits ordering__order_created' do
      customer = create(:customer)
      line_items = create_list(:line_item, 2)

      expect {
        Order.create(
          customer: customer,
          total_amount: 100.99,
          comment: 'Small order',
          line_items: line_items
        )
      }.to broadcast(
             :ordering__order_created,
             order_id: fetch_next_id_for(Order),
             total_amount: 100.99,
             comment: 'Small order',
             line_items: line_items
           )
    end
  end
end
```

### Testing handlers

Handlers can be tested by testing their `call!` method, that calls `call` behind the scenes.

Example:

```ruby
module Messaging
  RSpec.describe OrderingOrderCreatedHandler do
    describe '#call!' do
      it 'delivers order creation notification' do
        order = create(:order)
        event_data = event_data_for(
          'insights__person_created',
          order_id: order.id,
          total_amount: 100.99,
          comment: 'Small order',
          line_items: [build(:line_item)]
        )
        order_creation_notification = double(:order_creation_notification, deliver_now: true)
        allow(OrderMailer).to receive(:order_creation_notification).
          with(order).and_return(order_creation_notification)

        OrderingOrderCreatedHandler.new(event_data).call!

        expect(order_creation_notification).to have_received(:deliver_now)
      end
    end
  end
end
```

## Logger

[TODO]
