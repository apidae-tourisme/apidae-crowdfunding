class SubscriptionsMailer < ApplicationMailer
  def confirm_subscription(recipient_email)
    attachments['pionnier-apidae.png'] = File.read('./badges/badge-pionnier-apidae.png')
    mail(to: recipient_email, subject: "Confirmation de votre déclaration d’intention - Scic SA Apidae Tourisme")
  end
end
