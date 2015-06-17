require 'spec_helper'

describe Spree::Admin::OrdersHelper, type: :helper do
  context 'verify payments registered' do
    it 'should return true if one or more payments are registered in ClearSale' do
      order = FactoryGirl.build(:completed_order_with_pending_payment)
      order.payments << FactoryGirl.build(:check_payment)
      order.payments.first.clearsale_score = 'high'

      assign(:order, order)
      expect(helper.payments_registered_in_clearsale?).to be true
    end

    it 'should return false if any payments are registered in ClearSale' do
      order = FactoryGirl.build(:completed_order_with_pending_payment)

      assign(:order, order)
      expect(helper.payments_registered_in_clearsale?).to be false
    end
  end

  context 'show ClearSale score' do
    it 'should return the label of the score' do
      expect(helper.clearsale_score_label('low')).to eq "<span class='label label-clearsale-low'>Low</span>"
      expect(helper.clearsale_score_label('medium')).to eq "<span class='label label-clearsale-medium'>Medium</span>"
      expect(helper.clearsale_score_label('high')).to eq "<span class='label label-clearsale-high'>High</span>"
      expect(helper.clearsale_score_label('critical')).to eq "<span class='label label-clearsale-critical'>Critical</span>"
      # if has not score
      expect(helper.clearsale_score_label(nil)).to be_nil
    end
  end
end