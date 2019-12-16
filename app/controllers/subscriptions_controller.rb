class SubscriptionsController < ApplicationController
  def index
  end

  def new
    @subscription = Subscription.new
  end

  def create
    @subscription = Subscription.new(subscription_params)
    if @subscription.save
      SubscriptionsMailer.confirm_subscription(@subscription.email).deliver_now
      redirect_to confirm_subscriptions_url
    else
      flash.now[:alert] = "Une erreur s'est produite lors de l'enregistrement de la déclaration."
      render :new
    end
  end

  def members
    @members = []
    unless params[:pattern].blank?
      @members = ApidaeMember.lookup_by_name(params[:pattern])
    end
  end

  def confirm
  end

  def rankings
  end

  def proportions
  end

  private

  def subscription_params
    params.require(:subscription).permit!
  end
end
