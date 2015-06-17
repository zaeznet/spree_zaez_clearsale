require 'spec_helper'

describe Spree::CreditCard do
  context 'bin card' do
    it 'should save the BIN of the card' do
      cred_card = Spree::CreditCard.create(number: '1234567890000', month: '01', year: '2020',
                                           name: 'Spree Commerce', verification_value: '123')
      expect(cred_card.bin_card).to eq '123456'
    end
  end
end