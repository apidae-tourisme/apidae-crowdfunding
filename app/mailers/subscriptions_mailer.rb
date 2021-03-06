class SubscriptionsMailer < ApplicationMailer
  def confirm_subscription(subscription)
    @subscription = subscription
    attachments['pionnier-apidae.png'] = File.read('./badges/badge-pionnier-apidae.png')
    mail(to: @subscription.email_recipient, bcc: 'notification@souscription.apidae-tourisme.com',
         subject: "Confirmation de Souscription à Apidae Tourisme Scic SA à capital variable")
  end

  def complete_subscription(subscription)
    @subscription = subscription
    mail(to: @subscription.email_recipient, bcc: 'notification@souscription.apidae-tourisme.com',
         subject: "Confirmez votre prise de participation au capital Apidae Tourisme")
  end

  def declare_subscription(subscription)
    @subscription = subscription
    mail(to: @subscription.email_recipient, bcc: 'notification@souscription.apidae-tourisme.com',
         subject: "Confirmation de votre déclaration d'intention à Apidae Tourisme Scic SA à capital variable")
  end
end
