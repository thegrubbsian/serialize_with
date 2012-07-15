module Mongoid
  module SerializeWith

    def self.included(base)
      base.extend ::SerializeWith
    end

  end
end
