module PubSub
  module Domain
    def method_missing(event_or_method_name, *event_data)
      if handler_name(event_or_method_name)
        const_get(handler_name(event_or_method_name)).new(*event_data).call!
      else
        super
      end
    end

    def handler_name(event_name)
      return nil unless event_name.to_s.start_with?(/[a-z_]+__/)
      "#{event_name.to_s.camelize}Handler"
    end

    def respond_to_missing?(event_or_method_name, include_private = false)
      return super unless handler_name(event_or_method_name)
      const_get(handler_name(event_or_method_name))
    rescue NameError
      super
    end
  end
end
