require 'spec_helper'

describe 'ClearSale Settings', type: :feature do
  before { create_admin_in_sign_in }

  context 'visit ClearSale settings' do
    it 'should be a link to ClearSale settings' do
      within('.sidebar') { page.find_link('ClearSale Settings')['/admin/clear_sale_settings/edit'] }
    end
  end

  context 'show ClearSale settings' do

    before { visit spree.edit_admin_clear_sale_settings_path }

    it 'should show the preferences of ClearSale settings', js: true do
      expect(page).to have_selector '[name=state]'
      expect(page).to have_selector '#token'
      expect(page).to have_selector '#test_mode'
      expect(page).to have_selector '#doc_customer_attr'
      expect(page).to have_selector '#provider'
      expect(page).to have_selector '#payment_type'
      expect(page).to have_selector '#enable_birth_date'
      expect(page).to have_selector '#enable_category_taxonomy'
    end

    it 'should hide birth date customer attribute when checkbox enable_birth_date is disabled', js: true do
      find(:css, '#enable_birth_date').set false

      expect(page).not_to have_selector '#birth_date_customer_attr'
    end

    it 'should hide category taxonomy when checkbox enable_category_taxonomy is disabled', js: true do
      find(:css, '#enable_category_taxonomy').set false

      expect(page).not_to have_selector '#category_taxonomy_id'
    end
  end

  context 'edit ClearSale settings' do

    before do |example|
      unless example.metadata[:skip_before]
        visit spree.edit_admin_clear_sale_settings_path
      end
    end

    it 'can edit state', js: true do
      find(:css, '#state_false').set true
      click_button 'Update'

      expect(Spree::ClearSaleConfig.state).to be false
      expect(find_field('state_false')).to be_checked

      # set default
      Spree::ClearSaleConfig.state = true
    end

    it 'can edit token', js: true do
      fill_in 'Token', with: '123'
      click_button 'Update'

      verify_input_value 'token', Spree::ClearSaleConfig, '123', ''
    end

    it 'can edit test mode', js: true do
      find(:css, '#test_mode').set true
      click_button 'Update'

      expect(Spree::ClearSaleConfig.test_mode).to be true
      expect(find_field('test_mode')).to be_checked

      # set default
      Spree::ClearSaleConfig.test_mode = false
    end

    it 'can edit the providers', js: true do
      Spree::ClearSaleConfig.providers = {}
      # 1st provider
      select 'Spree::Gateway::BogusSimple', from: 'provider'
      select 'Bank Slip', from: 'payment_type'
      click_button 'Add'
      # 2nd provider
      select 'Spree::PaymentMethod::Check', from: 'provider'
      select 'Credit Card', from: 'payment_type'
      click_button 'Add'
      click_button 'Update'

      # 1st provider
      expect(Spree::ClearSaleConfig.providers.has_key?('Spree::Gateway::BogusSimple')).to be true
      expect(Spree::ClearSaleConfig.providers['Spree::Gateway::BogusSimple']).to eq '2'
      # 2nd provider
      expect(Spree::ClearSaleConfig.providers.has_key?('Spree::PaymentMethod::Check')).to be true
      expect(Spree::ClearSaleConfig.providers['Spree::PaymentMethod::Check']).to eq '1'

      within_row(1) do
        expect(column_text(1)).to eq('Spree::Gateway::BogusSimple')
        expect(column_text(2)).to eq('Bank Slip')
      end
      within_row(2) do
        expect(column_text(1)).to eq('Spree::PaymentMethod::Check')
        expect(column_text(2)).to eq('Credit Card')
      end

      # set default
      Spree::ClearSaleConfig.providers = {}
    end

    it 'can edit the document customer attribute', js: true do
      select 'Authentication Token', from: 'doc_customer_attr'
      click_button 'Update'

      verify_input_value 'doc_customer_attr', Spree::ClearSaleConfig, 'authentication_token', ''
    end

    it 'can edit the birth date customer attribute', js: true do
      find(:css, '#enable_birth_date').set true

      select 'Created At', from: 'birth_date_customer_attr'
      click_button 'Update'

      expect(Spree::ClearSaleConfig.birth_date_customer_attr).to eq 'created_at'
      expect(find_field('birth_date_customer_attr').value).to eq 'created_at'

      # set default
      Spree::ClearSaleConfig.birth_date_customer_attr = ''
    end

    it 'can edit the category taxonomy id',  skip_before: true do
      taxonomy = Spree::Taxonomy.create(name: 'Category')
      visit spree.edit_admin_clear_sale_settings_path

      find(:css, '#enable_category_taxonomy').set true

      select 'Category', from: 'category_taxonomy_id'
      click_button 'Update'

      expect(Spree::ClearSaleConfig.category_taxonomy_id).to eq taxonomy.id
      expect(find_field('category_taxonomy_id').value).to eq '1'

      # set default
      Spree::ClearSaleConfig.category_taxonomy_id = ''
    end
  end
end