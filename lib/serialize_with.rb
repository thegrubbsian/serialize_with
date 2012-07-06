require "serialize_with/version"

module SerializeWith

  def self.included(obj)
    obj.extend ClassMethods
  end

  module ClassMethods

    def serialize_with(options)
      define_method :serializable_hash do |opts|
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

end
