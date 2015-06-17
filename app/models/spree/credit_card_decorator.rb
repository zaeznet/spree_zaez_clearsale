Spree::CreditCard.class_eval do

  before_save :set_bin_card

  def set_bin_card
    number.to_s.gsub!(/\s/,'')
    self.bin_card ||= number.to_s.length <= 4 ? '' : number.to_s.slice(0..5)
  end

end