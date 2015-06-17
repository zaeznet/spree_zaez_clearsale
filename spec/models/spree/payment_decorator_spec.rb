require 'spec_helper'

describe Spree::Payment do

  let(:order) { FactoryGirl.build(:completed_order_with_pending_payment) }
  let(:payment) { FactoryGirl.build(:payment, order: order, created_at: Date.today) }

  context 'register payment in ClearSale' do
    it 'should return true if the payment is registered' do
      payment.clearsale_score = 'low'
      expect(payment.clearsale_registered?).to be true
    end
  end

  context 'send request to ClearSale' do

    before(:all) { Spree::ClearSaleConfig.providers = {'Spree::Gateway::Bogus' => 1} }

    after(:all) { Spree::ClearSaleConfig.providers = {} }

    it 'when score is low' do
      stub_request(:post, Spree::ClearSaleConfig.integration_url).
          with(:headers => {'Accept'=>'*/*',
                            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                            'Content-Type'=>'application/x-www-form-urlencoded',
                            'User-Agent'=>'Ruby'},
               :body => hash_including({'CodigoIntegracao'=>Spree::ClearSaleConfig.token})).
          to_return(:body => File.read('spec/fixtures/clearsale_low.txt'), :status => 200)

      payment.complete
      expect(payment.reload.clearsale_score).to eq 'low'
    end

    it 'when score is medium' do
      stub_request(:post, Spree::ClearSaleConfig.integration_url).
          with(:headers => {'Accept'=>'*/*',
                            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                            'Content-Type'=>'application/x-www-form-urlencoded',
                            'User-Agent'=>'Ruby'},
               :body => hash_including({'CodigoIntegracao'=>Spree::ClearSaleConfig.token})).
          to_return(:body => File.read('spec/fixtures/clearsale_medium.txt'), :status => 200)

      payment.complete
      expect(payment.reload.clearsale_score).to eq 'medium'
    end

    it 'when score is high' do
      stub_request(:post, Spree::ClearSaleConfig.integration_url).
          with(:headers => {'Accept'=>'*/*',
                            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                            'Content-Type'=>'application/x-www-form-urlencoded',
                            'User-Agent'=>'Ruby'},
               :body => hash_including({'CodigoIntegracao'=>Spree::ClearSaleConfig.token})).
          to_return(:body => File.read('spec/fixtures/clearsale_high.txt'), :status => 200)

      payment.complete
      expect(payment.reload.clearsale_score).to eq 'high'
    end

    it 'when score is critical' do
      stub_request(:post, Spree::ClearSaleConfig.integration_url).
          with(:headers => {'Accept'=>'*/*',
                            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                            'Content-Type'=>'application/x-www-form-urlencoded',
                            'User-Agent'=>'Ruby'},
               :body => hash_including({'CodigoIntegracao'=>Spree::ClearSaleConfig.token})).
          to_return(:body => File.read('spec/fixtures/clearsale_critical.txt'), :status => 200)

      payment.complete
      expect(payment.reload.clearsale_score).to eq 'critical'
    end
  end
end