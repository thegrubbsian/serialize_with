module SerializeWith
  class Railtie < Rails::Railtie
    initializer "serialize_with.extend_active_record", :after => "active_record.initialize_database" do |app|
      ActiveSupport.on_load(:active_record) do
        self.extend SerializeWith
      end
    end
  end
end
