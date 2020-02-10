class SubscriptionsMailer < ApplicationMailer
  def confirm_subscription(subscription)
    @subscription = subscription
    attachments['pionnier-apidae.png'] = File.read('./badges/badge-pionnier-apidae.png')
    mail(to: @subscription.email, subject: "Confirmation de votre déclaration d’intention - Scic SA Apidae Tourisme")
  end

  def complete_subscription(subscription)
    @subscription = subscription
    mail(to: @subscription.email, subject: "Souscription Scic SA Apidae Tourisme")
  end
end
