class SubscriptionsMailer < ApplicationMailer
  def confirm_subscription(recipient_email)
    mail(to: recipient_email, subject: "Confirmation de votre déclaration d’intention - Scic SA Apidae Tourisme")
  end
end
