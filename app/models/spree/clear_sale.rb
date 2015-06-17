module Spree
  module ClearSale

    # Registra o pagamento enviando
    # as informacoes a ClearSale
    #
    # @param payment [Spree::Payment]
    #
    # @author Isabella Santos
    #
    # @return [String]
    #
    def self.register_payment payment
      # nao permite guest checkout
      # pois para o registrar na ClearSale
      # é necessário o documento (CPF/CNPJ) do cliente
      # que não tem no guest checkout
      return '' if payment.order.user.nil?

      params = set_request_params payment
      uri = URI(Spree::ClearSaleConfig.integration_url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(params)
      response = https.request(request)

      doc = Nokogiri::HTML response.body
      risk = doc.css('.divScore').first.content rescue ''
      risk = risk.gsub("\r\n", '').strip
      risk
    end

    # Monta os dados da requisicao para a ClearSale
    # de acordo com o pagamento passado
    #
    # @author Isabella Santos
    #
    # @param payment [Spree::Payment]
    #
    # @return [Hash]
    #
    def self.set_request_params payment
      order = payment.order
      ship_address = order.ship_address
      bill_address = order.bill_address
      ship_phone_ddd = ship_address.phone[1..2]  rescue ''
      ship_phone     = ship_address.phone[5..-1] rescue ''
      bill_phone_ddd = bill_address.phone[1..2]  rescue ''
      bill_phone     = bill_address.phone[5..-1] rescue ''
      birth_date = order.user.attributes[Spree::ClearSaleConfig.birth_date_customer_attr].strftime('%d/%m/%Y %H:%M:%S') rescue ''

      # dados do cartao
      if payment.source.is_a? Spree::CreditCard
        credit_card = payment.source
        card_type   = verify_credit_card_type(credit_card.cc_type)
        bin_card    = credit_card.bin_card
        last_digits = credit_card.last_digits
        number_card = "#{credit_card.bin_card}******#{credit_card.last_digits}"
      else
        card_type, bin_card, last_digits, number_card = ''
      end

      params = {CodigoIntegracao: Spree::ClearSaleConfig.token,
                PedidoID: payment.number,
                Data: payment.created_at.strftime('%d/%m/%Y %H:%M:%S'),
                IP: order.last_ip_address,
                Total: payment.amount.to_s,
                TipoPagamento: Spree::ClearSaleConfig.providers[payment.payment_method.class.to_s].to_i,
                TipoCartao: card_type,
                Cartao_Bin: bin_card,
                Cartao_Fim: last_digits,
                Cartao_Numero_Mascarado: number_card,

                Cobranca_Nome: "#{bill_address.firstname} #{bill_address.lastname}",
                Cobranca_Nascimento: birth_date,
                Cobranca_Email: order.user.email,
                Cobranca_Documento: order.user.attributes[Spree::ClearSaleConfig.doc_customer_attr],
                Cobranca_Logradouro: bill_address.address1,
                Cobranca_Bairro: bill_address.address2,
                Cobranca_Cidade: bill_address.city,
                Cobranca_Estado: bill_address.state.abbr,
                Cobranca_CEP: bill_address.zipcode,
                Cobranca_Pais: bill_address.country.name,
                Cobranca_DDD_Telefone_1: bill_phone_ddd,
                Cobranca_Telefone_1: bill_phone,

                Entrega_Nome: "#{ship_address.firstname} #{ship_address.lastname}",
                Entrega_Nascimento: birth_date,
                Entrega_Email: order.user.email,
                Entrega_Documento: order.user.attributes[Spree::ClearSaleConfig.doc_customer_attr],
                Entrega_Logradouro: ship_address.address1,
                Entrega_Bairro: ship_address.address2,
                Entrega_Cidade: ship_address.city,
                Entrega_Estado: ship_address.state.abbr,
                Entrega_CEP: ship_address.zipcode,
                Entrega_Pais: ship_address.country.name,
                Entrega_DDD_Telefone_1: ship_phone_ddd,
                Entrega_Telefone_1: ship_phone
      }

      if Spree::Config[:alternative_shipping_phone]
        bill_phone_ddd = bill_address.alternative_phone[1..2]  rescue ''
        bill_phone     = bill_address.alternative_phone[5..-1] rescue ''
        params[:Cobranca_DDD_Telefone_2] = bill_phone_ddd
        params[:Cobranca_Telefone_2]     = bill_phone

        ship_phone_ddd = ship_address.alternative_phone[1..2]  rescue ''
        ship_phone     = ship_address.alternative_phone[5..-1] rescue ''
        params[:Entrega_DDD_Telefone_2] = ship_phone_ddd
        params[:Entrega_Telefone_2]     = ship_phone
      end

      order.line_items.each_with_index do |item, cont|
        if Spree::ClearSaleConfig.category_taxonomy_id > 0
          taxons = item.variant.product.taxons.where(taxonomy_id: Spree::ClearSaleConfig.category_taxonomy_id) rescue ''
          brand_name = taxons.first.name rescue ''
        else
          brand_name = item.variant.product.taxons.first.name rescue ''
        end
        params["Item_ID_#{cont+1}".to_sym]        = item.variant_id
        params["Item_Nome_#{cont+1}".to_sym]      = item.variant.name
        params["Item_Qtd_#{cont+1}".to_sym]       = item.quantity
        params["Item_Valor_#{cont+1}".to_sym]     = item.price.to_s
        params["Item_Categoria_#{cont+1}".to_sym] = brand_name
      end

      params
    end

    # Retorna o codigo do cartao de acordo
    # com a tabela fornecida pela ClearSale
    #
    # @author Isabella Santos
    #
    # @param type [String]
    #
    # @return [Integer]
    #
    def self.verify_credit_card_type type
      case type
        when 'diners'           then 1
        when 'master'           then 2
        when 'visa'             then 3
        when 'american_express' then 5
        when 'hiper_card'       then 6
        when 'aura'             then 7
        when 'carrefour'        then 8
        else 4
      end
    end
  end
end