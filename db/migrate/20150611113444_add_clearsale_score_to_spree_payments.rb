class AddClearsaleScoreToSpreePayments < ActiveRecord::Migration
  def change
    add_column :spree_payments, :clearsale_score, :string
  end
end
