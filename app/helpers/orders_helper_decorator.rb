Spree::Admin::OrdersHelper.class_eval do

  def payments_registered_in_clearsale?
    @order.payments.each { |pay| return true if pay.clearsale_registered? }
    false
  end

  def clearsale_score_label score
    return nil if score.nil?
    "<span class='label label-clearsale-#{score}'>#{Spree.t("clearsale_score_#{score}")}</span>".html_safe
  end
end