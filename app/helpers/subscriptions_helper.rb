module SubscriptionsHelper
  def subscription_categories
    CATEGORIES.map {|ref, cat| [cat[:name], ref.to_s]}
  end
end
