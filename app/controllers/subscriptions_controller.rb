class SubscriptionsController < ApplicationController
  def index
  end

  def new
    @subscription = Subscription.new
  end

  def create
    @subscription = Subscription.new(subscription_params)
    if @subscription.save
      # email
      redirect_to confirm_subscriptions_url
    else
      flash.now[:alert] = "Une erreur s'est produite lors de l'enregistrement de la déclaration."
      render :new
    end
  end

  def confirm
  end

  private

  def subscription_params
    params.require(:subscription).permit!
  end
end
