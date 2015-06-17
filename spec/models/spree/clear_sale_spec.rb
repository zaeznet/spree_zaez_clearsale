require 'spec_helper'

describe 'Spree::ClearSale' do

  let(:dummy_module) { Spree::ClearSale }

  context 'request to ClearSale' do
    let(:order) { FactoryGirl.build(:completed_order_with_pending_payment) }
    let(:payment) { FactoryGirl.build(:payment, order: order, created_at: Date.today) }

    it 'should send a request to ClearSale and return the score' do
      stub = stub_request(:post, Spree::ClearSaleConfig.integration_url).
          with(:headers => {'Accept'=>'*/*',
                            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                            'Content-Type'=>'application/x-www-form-urlencoded',
                            'User-Agent'=>'Ruby'},
               :body => hash_including({'CodigoIntegracao'=>Spree::ClearSaleConfig.token})).
          to_return(:body => File.read('spec/fixtures/clearsale_high.txt'), :status => 200)

      response = dummy_module.register_payment payment

      expect(stub).to have_been_requested
      expect(response).to eq 'ALTO'
    end
  end

  context 'information to ClearSale' do
    it 'should return the code of the credit card' do
      expect(dummy_module.verify_credit_card_type('diners')).to eq 1
      expect(dummy_module.verify_credit_card_type('master')).to eq 2
      expect(dummy_module.verify_credit_card_type('visa')).to eq 3
      expect(dummy_module.verify_credit_card_type('american_express')).to eq 5
      expect(dummy_module.verify_credit_card_type('hiper_card')).to eq 6
      expect(dummy_module.verify_credit_card_type('aura')).to eq 7
      expect(dummy_module.verify_credit_card_type('carrefour')).to eq 8
      # Other types
      expect(dummy_module.verify_credit_card_type('some bank')).to eq 4
    end

    context 'set params' do
      let(:order) { FactoryGirl.build(:completed_order_with_pending_payment) }
      let(:payment) { FactoryGirl.build(:payment, order: order, created_at: Date.today) }

      it 'should set the alternative phone' do
        # set the alternative phone in Spree
        Spree::Config[:alternative_shipping_phone] = true
        params = dummy_module.set_request_params payment

        expect(params.has_key?(:Cobranca_DDD_Telefone_2)).to be true
        expect(params.has_key?(:Cobranca_Telefone_2)).to     be true
        expect(params.has_key?(:Entrega_DDD_Telefone_2)).to  be true
        expect(params.has_key?(:Entrega_Telefone_2)).to      be true
      end

      it 'should show all line items' do
        line_item1 = FactoryGirl.build(:line_item, order: order, quantity: 1, price: 10)
        line_item2 = FactoryGirl.build(:line_item, order: order, quantity: 2, price: 7)
        order.line_items.push [line_item1, line_item2]
        params = dummy_module.set_request_params payment

        order.line_items.each_with_index do |item, cont|
          expect(params["Item_ID_#{cont+1}".to_sym]).to eq item.variant.id
          expect(params["Item_Nome_#{cont+1}".to_sym]).to eq item.variant.name
          expect(params["Item_Qtd_#{cont+1}".to_sym]).to eq item.quantity
          expect(params["Item_Valor_#{cont+1}".to_sym]).to eq item.price.to_s
        end
      end

      context 'category of the product' do

        let(:taxon)     { FactoryGirl.build(:taxon, name: 'Bags') }
        let(:product)   { FactoryGirl.build(:product, taxons: [taxon]) }
        let(:line_item) { FactoryGirl.build(:line_item, order: order, quantity: 1, price: 20, variant: product.master) }

        before { order.line_items << line_item }

        it 'should set the first taxon to category when category taxonomy is not defined' do
          # default
          Spree::ClearSaleConfig.category_taxonomy_id = 0

          params = dummy_module.set_request_params payment

          expect(params[:Item_Categoria_1]).to eq 'Bags'
        end

        it 'should set the first taxon which represents the category taxonomy' do
          taxonomy = FactoryGirl.build(:taxonomy, name: 'Categories', id: 1)
          category_taxon = FactoryGirl.build(:taxon, name: 'Shirts', taxonomy: taxonomy)
          product.taxons << category_taxon
          Spree::ClearSaleConfig.category_taxonomy_id = taxonomy.id

          # stub method :where of taxons
          allow(product.taxons).to receive(:where).and_return([category_taxon])
          params = dummy_module.set_request_params payment

          expect(params[:Item_Categoria_1]).to eq 'Shirts'

          # set default
          Spree::ClearSaleConfig.category_taxonomy_id = 0
        end
      end

      context 'set credit card information' do
        it 'should set credit card information if the payment method is credit card' do
          pay_credit_card = FactoryGirl.build(:payment, order: order, created_at: Date.today)
          params = dummy_module.set_request_params pay_credit_card

          expect(params[:TipoCartao]).to eq dummy_module.verify_credit_card_type(pay_credit_card.source.cc_type)
          expect(params[:Cartao_Bin]).to eq pay_credit_card.source.bin_card
          expect(params[:Cartao_Fim]).to eq pay_credit_card.source.last_digits
          expect(params[:Cartao_Numero_Mascarado]).to eq "#{pay_credit_card.source.bin_card}******#{pay_credit_card.source.last_digits}"
        end

        it 'should not set credit card information if the payment method is not credit card' do
          pay_check = FactoryGirl.build(:check_payment, order: order, created_at: Date.today)
          params = dummy_module.set_request_params pay_check

          expect(params[:TipoCartao]).to be_blank
          expect(params[:Cartao_Bin]).to be_blank
          expect(params[:Cartao_Fim]).to be_blank
          expect(params[:Cartao_Numero_Mascarado]).to be_blank
        end
      end
    end
  end
end