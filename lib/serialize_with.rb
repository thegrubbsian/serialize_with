require "serialize_with/version"
require "serialize_with/railtie" if defined?(Rails)

module SerializeWith

  def serialize_with(context, options = {})
    options, context = context, :default unless context.is_a?(Symbol)
    __setup_serialize_with unless self.respond_to?(:__serialization_options)
    self.__serialization_options[context] = options
  end

  private

  def __setup_serialize_with
    self.class_attribute :__serialization_options
    self.__serialization_options = {}
    include InstanceMethods
  end

  module InstanceMethods

    MERGE_KEYS = [:include, :methods]
    OVERRIDE_KEYS = [:only, :except]

    def as_json(context = nil, options = {})
      super(__prepare_options_arguments(context, options))
    end

    def to_xml(context = nil, options = {})
      super(__prepare_options_arguments(context, options))
    end

    def serializable_hash(local_options)
      local_options ||= {}
      context = local_options[:context] || :default
      options = self.class.__serialization_options
      merged_options = __merge_serialization_options(context, local_options, options)
      HashWithIndifferentAccess.new(super(merged_options))
    end

    private

    def __merge_serialization_options(context, local_options, options)
      MERGE_KEYS.each do |key|
        next unless options[context][key]
        local_options[key] ||= []
        local_options[key] += options[context][key]
      end
      OVERRIDE_KEYS.each do |key|
        local_options[key] = options[context][key] unless local_options[key]
      end
      local_options
    end

    def __prepare_options_arguments(context, options)
      options[:context] = context if context.is_a?(Symbol)
      options = context if context.is_a?(Hash)
      options
    end

  end

end
