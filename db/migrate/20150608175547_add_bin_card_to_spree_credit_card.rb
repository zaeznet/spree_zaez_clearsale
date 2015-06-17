class AddBinCardToSpreeCreditCard < ActiveRecord::Migration
  def change
    add_column :spree_credit_cards, :bin_card, :string
  end
end
