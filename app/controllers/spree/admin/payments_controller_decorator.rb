Spree::Admin::PaymentsController.class_eval do

  before_action :load_payment, except: [:create, :new, :index, :clear_sale]

  def clear_sale
    @integration_url = "#{Spree::ClearSaleConfig.integration_url}?codigointegracao=#{Spree::ClearSaleConfig.token}&PedidoID="
  end

end