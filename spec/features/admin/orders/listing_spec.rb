require 'spec_helper'

describe 'Listing Orders', type: :feature do

  let(:order1) do
    create :order,
           created_at: 1.day.from_now,
           completed_at: 1.day.from_now,
           number: 'R100'
  end
  let(:order2) do
    create :order,
           created_at: Date.today,
           completed_at: Date.today,
           number: 'R200'
  end
  let(:payment1) { FactoryGirl.build(:payment, clearsale_score: 'critical', order: order1) }
  let(:payment2) { FactoryGirl.build(:payment, clearsale_score: 'low', order: order2) }
  let(:payment3) { FactoryGirl.build(:payment, clearsale_score: 'high', order: order2) }

  before do
    create_admin_in_sign_in
    order1; order2
    order1.payments << payment1
    order2.payments.push [payment2, payment3]

    visit spree.admin_orders_path
  end

  it 'should replace order considered risk for ClearSale score', js: true do
    expect(page).not_to have_text 'Risky'
    expect(page).to have_text 'CLEARSALE SCORE'
  end

  it 'should show the ClearSale score', js: true do
    within_row(1) do
      expect(find('td:nth-child(3)')).to have_css '.label-clearsale-critical'
      expect(column_text(3)).to eq 'Critical'
    end

    within_row(2) do
      expect(find('td:nth-child(3)')).to have_css '.label-clearsale-high'
      expect(find('td:nth-child(3)')).to have_css '.label-clearsale-low'
      expect(column_text(3)).to eq 'Low High'
    end
  end
end