# Preview all emails at http://localhost:3000/rails/mailers/subscriptions_mailer
class SubscriptionsMailerPreview < ActionMailer::Preview
  def confirm_subscription
    SubscriptionsMailer.confirm_subscription(Subscription.last)
  end

  def complete_subscription
    SubscriptionsMailer.complete_subscription(Subscription.last)
  end

  def declare_subscription
    SubscriptionsMailer.declare_subscription(Subscription.last)
  end
end
