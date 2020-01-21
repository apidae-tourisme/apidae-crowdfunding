class Admin::SubscriptionsController < Admin::UserController
  before_action :check_credentials

  def index
    @subscriptions = Subscription.all
  end

  def update
    @subscription = Subscription.find(params[:id])
    if @subscription.update(subscription_params)
      flash[:notice] = "La souscription a bien été mise à jour."
    else
      flash[:alert] = "Une erreur s'est produite lors de la mise à jour de la souscription."
    end
  end

  private

  def check_credentials
    authenticate_user!
    unless Rails.application.config.subscriptions_admins.include?(current_user.email)
      redirect_to root_url, alert: "Vous n'êtes pas autorisé(e) à accéder à cette page."
    end
  end

  def subscription_params
    params.require(:subscription).permit(:com_enabled)
  end
end
