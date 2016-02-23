class Spree::Admin::ClearSaleSettingsController < Spree::Admin::BaseController

  def edit
    @config = Spree::ClearSaleConfiguration.new
    @providers = Spree::Gateway.providers.sort { |p1, p2| p1.name <=> p2.name }
    @user_attr = Spree::User.new.attribute_names.sort_by { |item| item }
    @taxonomies = Spree::Taxonomy.all
  end

  def update
    config = Spree::ClearSaleConfiguration.new

    params.each do |name, value|
      next if !config.has_preference?(name) or name == 'providers'
      config[name] = value
    end

    config[:test_mode] = false unless params.has_key? :test_mode

    # adiciona os providers na preference
    # junto de seu tipo de pagamento
    if params[:providers].present?
      providers = {}
      params[:providers].each_with_index do |provider, cont|
        next if provider.blank?
        providers[provider] = params[:payment_types][cont]
      end
      Spree::ClearSaleConfig.providers = providers
    end

    flash[:success] = Spree.t(:successfully_updated, resource: Spree.t(:clear_sale_settings))
    redirect_to edit_admin_clear_sale_settings_path
  end

end