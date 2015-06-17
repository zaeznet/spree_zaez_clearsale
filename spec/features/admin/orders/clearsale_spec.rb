require 'spec_helper'

describe 'ClearSale', type: :feature do

  def visit_order
    create_admin_in_sign_in

    visit spree.admin_path
    within('.sidebar') do
      click_link 'Orders'
    end
    within_row(1) do
      click_link order.number
    end
  end

  let!(:order) do
    create(:completed_order_with_pending_payment)
  end

  context 'without payments registered in ClearSale' do
    it 'should not show ClearSale tab when any payment is registered', js: true do
      visit_order
      expect(page).not_to have_content 'ClearSale'
    end
  end

  context 'with payment registered in ClearSale' do
    it 'should show ClearSale tab when a payment is registered', js: true do
      Spree::ClearSaleConfig.providers = {'Spree::Gateway::Bogus' => 1}
      Spree::ClearSaleConfig.test_mode = true

      stub_request(:post, Spree::ClearSaleConfig.integration_url).
          with(:headers => {'Accept'=>'*/*',
                            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                            'Content-Type'=>'application/x-www-form-urlencoded',
                            'User-Agent'=>'Ruby'},
               :body => hash_including({'CodigoIntegracao' => Spree::ClearSaleConfig.token})).
          to_return(:body => File.read('spec/fixtures/clearsale_critical.txt'), :status => 200 )

      visit_order
      within('.main-right-sidebar') do
        click_link 'Payments'
      end
      click_icon(:capture)

      Spree::ClearSaleConfig.birth_date_customer_attr
      expect(order.payments.first.reload.clearsale_score).to eq 'critical'
      expect(page).to have_content 'ClearSale'

      within('.main-right-sidebar') do
        click_link 'ClearSale'
      end

      # set default
      Spree::ClearSaleConfig.providers = {}
      Spree::ClearSaleConfig.test_mode = false
    end
  end
end