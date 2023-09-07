module PubSub
  class EventClassFactory
    EventClassDoesNotExist = Class.new(StandardError)

    def self.build(event_name, domain_name: nil, abstract_event_class: nil)
      new(
        event_name,
        domain_name:,
        abstract_event_class:
      ).build_event_class
    end

    def initialize(event_name, domain_name:, abstract_event_class:)
      @event_name = event_name.to_s
      @abstract_event_class = abstract_event_class
      @domain_name = domain_name
    end

    def build_event_class
      event_class = res_event_class_name.safe_constantize

      return event_class if event_class.present?

      event_class = event_class_name.safe_constantize

      return event_class if event_class.present?

      if abstract_event_class.nil?
        raise(EventClassDoesNotExist, event_class_name)
      else
        register_new_event_class
      end
    end

    private

    attr_reader :event_name, :abstract_event_class, :domain_name

    def register_new_event_class
      event_class_namespace.const_set(event_class_name.demodulize, Class.new(abstract_event_class))
    end

    def event_class_namespace
      event_class_name.deconstantize.constantize
    end

    def event_name_includes_domain?
      event_name.include?('__')
    end

    def event_name_with_domain
      if event_name_includes_domain?
        event_name.to_s.downcase.sub('__', '/')
      else
        [domain_name&.underscore, event_name].compact.join('/')
      end
    end

    def res_event_class_name
      @res_event_class_name ||= "pub_sub/#{event_name_with_domain}_event".classify
    end

    def event_class_name
      @event_class_name ||= "#{event_name_with_domain}_event".classify
    end
  end
end
