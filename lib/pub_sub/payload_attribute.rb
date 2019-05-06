module PubSub
  class PayloadAttribute
    CannotEvaluate = Class.new(StandardError)

    def initialize(attribute_name, explicit_payload, context)
      @attribute_name = attribute_name
      @explicit_payload = explicit_payload
      @context = context
    end

    def get
      return explicit_payload.fetch(attribute_name) if explicit_payload.key?(attribute_name)

      identifier? ? context.send(getter_name)&.id : context.send(getter_name)
    rescue NoMethodError
      raise CannotEvaluate, getter_name
    end

    private

    attr_reader :attribute_name, :explicit_payload, :context

    def identifier?
      !context.respond_to?(attribute_name, true) && attribute_name.to_s.end_with?('_id')
    end

    def getter_name
      identifier? ? attribute_name.to_s.chomp('_id') : attribute_name
    end
  end
end
