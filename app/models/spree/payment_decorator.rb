Spree::Payment.class_eval do

  state_machine.after_transition on: :complete, do: :call_clearsale

  # Cria o objeto ClearSale
  # com as informacoes do pagamento
  #
  # @author Isabella Santos
  #
  def call_clearsale
    if Spree::ClearSaleConfig.state and Spree::ClearSaleConfig.providers.has_key?(self.payment_method.class.to_s)
      response = Spree::ClearSale.register_payment self
      cs_status = case response.mb_chars.downcase.to_s
                    when 'baixo'   then :low
                    when 'médio'   then :medium
                    when 'alto'    then :high
                    when 'crítico' then :critical
                  end
      self.update(clearsale_score: cs_status)
    end
  end

  # Retorna se o pagamento foi registrado na ClearSale
  # verificando se ele tem
  #
  # @author Isabella Santos
  #
  # @return [Boolean]
  #
  def clearsale_registered?
    clearsale_score.present?
  end
end