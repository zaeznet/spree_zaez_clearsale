module SpreeZaezClearsale
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_zaez_clearsale'

    initializer 'spree.zaez_clearsale.preferences', :before => :load_config_initializers do |app|
      # require file with the preferences of the ClearSale
      require 'spree/clear_sale_configuration'
      Spree::ClearSaleConfig = Spree::ClearSaleConfiguration.new
      #
    end

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
