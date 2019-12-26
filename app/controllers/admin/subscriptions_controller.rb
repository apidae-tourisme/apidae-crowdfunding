class Admin::SubscriptionsController < Admin::UserController
  before_action :authenticate_user!

  def index
    @subscriptions = Subscription.all
  end

  def export
  end

  private

  def check_credentials
    authenticate_user!
    unless Rails.application.config.widgit_admins.include?(current_user.email)
      redirect_to root_url, alert: "Vous n'êtes pas autorisé(e) à accéder à cette page."
    end
  end
end
