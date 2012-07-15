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
    include MongoidSerializationOverrides if defined?(Mongoid)
  end

  module InstanceMethods

    def as_json(context = nil, options = {})
      super(__prepare_options_arguments(context, options))
    end

    def to_xml(context = nil, options = {})
      super(__prepare_options_arguments(context, options))
    end

    def serializable_hash(local_options = nil)
      local_options ||= {}
      context = local_options[:context] || :default
      options = self.class.__serialization_options
      merged_options = __merge_serialization_options(context, local_options, options)
      HashWithIndifferentAccess.new(super(merged_options))
    end

    private

    def __merge_serialization_options(context, local_options, options)
      [:include, :methods].each do |key|
        next unless options[context] && options[context][key]
        local_options[key] ||= []
        local_options[key] += Array.wrap(options[context][key])
      end
      [:only, :except].each do |key|
        next unless options[context] && options[context][key]
        local_options[key] = Array.wrap(options[context][key]) unless local_options[key]
      end
      local_options
    end

    def __prepare_options_arguments(context, options)
      options[:context] = context if context.is_a?(Symbol)
      options = context if context.is_a?(Hash)
      options
    end

  end

  # This overrides the serialize_relations method in Mongoid::Serialization to
  # prevent it from passing serialization options through to relations.
  module MongoidSerializationOverrides

    def serialize_relations(attributes = {}, options = {})
      inclusions = options[:include]
      relation_names(inclusions).each do |name|
        metadata = relations[name.to_s]
        if metadata && relation = send(metadata.name)
          attributes[metadata.name.to_s] =
            relation.serializable_hash #(relation_options(inclusions, options, name))
        end
      end
    end

    def relation_names(inclusions)
      inclusions.is_a?(Hash) ? inclusions.keys : Array.wrap(inclusions)
    end

  end

end
