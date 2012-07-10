require "serialize_with/version"

module SerializeWith

  def self.extended(obj)
    obj.class_attribute :__serialization_options
  end

  def serialize_with(options)
    self.__serialization_options = options
    include InstanceMethods
  end

  module InstanceMethods

    def serializable_hash(opts)
      options = self.class.__serialization_options || {}
      options = options.dup
      opts ||= {}

      options[:include] = [] if options[:include].nil?
      options[:include] += opts[:include].to_a

      options[:methods] = [] if options[:methods].nil?
      options[:methods] += opts[:methods].to_a

      options[:except] = [] if options[:except].nil?
      options[:except] += opts[:except].to_a

      super(options)
    end

  end

end
