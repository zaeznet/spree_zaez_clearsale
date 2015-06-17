class Spree::ClearSaleConfiguration < Spree::Preferences::Configuration

  preference :state,      :boolean, default: true             # modulo habilitado/desabilitado
  preference :test_mode,  :boolean, default: false            # modo de teste
  preference :token,      :string,  default: ''               # codigo de integracao
  preference :providers,  :hash,    default: {}               # quais tipos de pagamento o clearsale sera utilizado
  preference :doc_customer_attr,        :string               # campo que fica armazenado o CPF/CNPJ do cliente
  preference :birth_date_customer_attr, :string               # campo que fica armazenado a data de nascimento do cliente
  preference :category_taxonomy_id,     :integer, default: 0  # taxonmy que representa a categoria

  # Retorna um json com as informacoes dos providers
  # e seus tipos de pagamento (de acordo com a tabela da ClearSale) salvos
  #
  # @author Isabella Santos
  #
  # @return [String]
  #
  def get_providers
    preferred_providers.collect { |key, value| {id: key, text: key, payment_type: {id: value, text: Spree.t("payment_type_#{value}")}} }.to_json
  end

  # Retorna a url de integracao
  # de acordo com o modo selecionado (homologacao ou producao)
  #
  # @author Isabella Santos
  #
  # @return [String]
  #
  def integration_url
    if preferred_test_mode
      'https://homolog.clearsale.com.br/start/Entrada/EnviarPedido.aspx'
    else
      'https://www.clearsale.com.br/start/Entrada/EnviarPedido.aspx'
    end
  end
end