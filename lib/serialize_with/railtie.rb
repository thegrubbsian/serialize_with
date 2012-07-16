module SerializeWith
  class Railtie < Rails::Railtie
    initializer "serialize_with.extend_active_record_base" do |app|
      if defined?(ActiveRecord)
        ActiveSupport.on_load(:active_record) do
          ActiveRecord::Base.send(:include, SerializeWith)
        end
      end
    end
  end
end
