RSpec::Matchers.define :subscribe_to do |event_name|
  match do |domain|
    handler_class = build_handler_class(event_name, domain)
    event_class = build_event_class(event_name)
    subscription_type = async? ? :async : :sync

    expect(
      PubSub::EventHandlerBuilder.new(handler_class, subscription_type)
    ).to have_subscribed_to_events(event_class).in(event_store)
  end

  chain :asynchronously do
    @asynchronously = true
  end

  private

  def build_handler_class(event_name, domain)
    handler_name = event_name.to_s.sub('__', '/').camelize
    handler_name.remove!('::')
    "#{domain.name}::#{handler_name}Handler".constantize
  end

  def build_event_class(event_name)
    event_class_name = event_name.to_s.sub('__', '/').camelize
    "PubSub::#{event_class_name}Event".constantize
  end

  def async?
    @asynchronously
  end
end
