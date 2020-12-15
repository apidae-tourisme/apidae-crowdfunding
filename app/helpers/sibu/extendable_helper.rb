module Sibu
  module ExtendableHelper
    def amount_ratio
      [100, (total_amount / 750000.0).round(2) * 100].min.to_i
    end

    def total_amount
      Subscription.sum(:amount).to_i
    end

    def subscriptions_count
      Subscription.count
    end

    def colors_cycle
      cycle('danger', 'primary', 'warning', name: 'colors')
    end
  end
end