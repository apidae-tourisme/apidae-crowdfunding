class SubscriptionsMailer < ApplicationMailer
  def confirm_subscription(subscription)
    @subscription = subscription
    attachments['pionnier-apidae.png'] = File.read('./badges/badge-pionnier-apidae.png')
    mail(to: @subscription.email, subject: "Confirmation de Souscription à Apidae Tourisme Scic SA à capital variable")
  end

  def complete_subscription(subscription)
    @subscription = subscription
    mail(to: @subscription.email, subject: "Apidae Tourisme Scic SA à capital variable")
  end
end
