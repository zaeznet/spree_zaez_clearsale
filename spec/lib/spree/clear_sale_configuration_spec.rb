require 'spec_helper'

describe Spree::ClearSaleConfiguration do
  before do
    @object = Spree::ClearSaleConfiguration.new
  end

  [:token, :test_mode, :providers, :doc_customer_attr,
   :birth_date_customer_attr, :category_taxonomy_id].each do |preference|
    it "should have the #{preference} preference" do
      expect(@object.has_preference?(preference)).to be true
    end
  end

  it 'should show the providers in get_providers' do
    @object.providers = {'some_provider' => '1'}
    response = JSON.parse @object.get_providers

    expect(response.first['id']).to eq 'some_provider'
    expect(response.first['text']).to eq 'some_provider'
    expect(response.first['payment_type']).to eq({'id' => '1', 'text' => Spree.t('payment_type_1')})

    # set default
    @object.providers = {}
  end

  context 'integration_url' do
    it 'should return the url of production' do
      @object.test_mode = false
      expect(@object.integration_url).to eq 'https://www.clearsale.com.br/start/Entrada/EnviarPedido.aspx'
    end

    it 'should return the url of test' do
      @object.test_mode = true
      expect(@object.integration_url).to eq 'https://homolog.clearsale.com.br/start/Entrada/EnviarPedido.aspx'

      # set default
      @object.test_mode = false
    end
  end
end