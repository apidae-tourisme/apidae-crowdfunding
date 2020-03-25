class Admin::SubscriptionsController < Admin::UserController
  before_action :check_credentials

  def index
    @subscriptions = Subscription.all.order(created_at: :desc)
  end

  def update
    @subscription = Subscription.find(Subscription.decrypt(params[:id]))
    if @subscription.update(subscription_params)
      flash[:notice] = "La souscription a bien été mise à jour."
    else
      flash[:alert] = "Une erreur s'est produite lors de la mise à jour de la souscription."
    end
  end

  def sync_crm
    @subscription = Subscription.find(Subscription.decrypt(params[:id]))
    begin
      CrmClient.add_or_update(@subscription)
      flash[:notice] = "La souscription a bien été enregistrée dans la base GRC."
    rescue StandardError => e
      logger.error "sync_crm failed : #{e.message}"
      logger.error e.backtrace.first
      flash[:alert] = "Une erreur s'est produite lors de l'enregistrement des la souscription dans la base GRC."
    end
  end

  def send_mail
    @subscription = Subscription.find(Subscription.decrypt(params[:id]))
    if params[:mailer_action] == 'confirm_subscription' || params[:mailer_action] == 'declare_subscription'
      SubscriptionsMailer.send(params[:mailer_action].to_sym, @subscription).deliver_now
      flash[:notice] = "L'email a bien été envoyé."
    else
      flash[:alert] = "Une erreur s'est produite lors de l'envoi de l'email."
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
