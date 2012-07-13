require "serialize_with/version"

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

    MERGE_KEYS = [:include, :methods, :except]

    def serializable_hash(local_options)
      local_options ||= {}
      context = local_options[:context] || :default
      options = self.class.__serialization_options
      merged_options = __merge_serialization_options(context, local_options, options)
      super(merged_options)
    end

    private

    def __merge_serialization_options(context, local_options, options)
      MERGE_KEYS.each do |key|
        next unless options[context][key]
        local_options[key] ||= []
        local_options[key] += options[context][key]
      end
      local_options
    end

  end

end
