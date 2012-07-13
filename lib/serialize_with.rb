require "serialize_with/version"

module SerializeWith

  def serialize_with(options)
    self.class_attribute :__serialization_options
    self.__serialization_options = options
    include InstanceMethods
  end

  module InstanceMethods

    MERGE_KEYS = [:include, :methods, :except]

    def serializable_hash(local_options)
      options = self.class.__serialization_options.clone
      local_options ||= {}
      MERGE_KEYS.each do |key|
        options[key] = [] unless options[key]
        options[key] += local_options[key].to_a
      end
      super(options)
    end

  end

end
