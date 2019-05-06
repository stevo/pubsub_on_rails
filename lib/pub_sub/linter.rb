class Linter
  MissingSubscriptions = Class.new(StandardError)

  def initialize(config)
    @config = config
  end

  def lint!
    raise MissingSubscriptions, error_message if missing_subscriptions.present?
  end

  private

  def error_message
    "The following subscriptions are missing: \n#{missing_subscriptions.join("\n")}"
  end

  def missing_subscriptions
    (handlers_list - subscriptions_list)
  end

  attr_reader :config

  def subscriptions_list
    config.flat_map do |domain_name, subscriptions|
      subscriptions.keys.map do |event_name|
        "#{domain_name}/#{event_name.sub('__', '_')}"
      end
    end
  end

  def handlers_list
    Dir[Rails.root.join('app/event_handlers/*/*.rb')].map do |file_path|
      file_path.
        sub("#{Rails.root}/app/event_handlers/", '').
        sub('_handler.rb', '')
    end
  end
end
