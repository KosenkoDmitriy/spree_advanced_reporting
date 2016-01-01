module ReportsHelper
  def credit_card_types(payments)
    @credit_cards_types ||= credit_card_payments(payments).collect { |p| credit_card_type(p) }.uniq
  end

  def credit_card_payments(payments)
    @credit_card_payments ||= payments.select { |p| p.source.is_a?(Spree::CreditCard) }
  end

  def payments_by_card_type(payments)
    credit_card_payments(payments).reduce({}) do |m, p|
      m[credit_card_type(p)] ||= []
      m[credit_card_type(p)] << p
      m
    end
  end

  def credit_card_type(payment)
    payment.source.cc_type
  end

  def credit_card_humanizer(str)
    str.present? ? str.humanize : '(unknown)'
  end
end
