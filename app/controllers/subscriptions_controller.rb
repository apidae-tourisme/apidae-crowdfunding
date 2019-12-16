class SubscriptionsController < ApplicationController
  def index
    @subscriptions = Subscription.all.select(:label, :amount, :category)
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
    @subscriptions = Subscription.all.select(:label, :amount, :category).order(amount: :desc).limit(5)
  end

  def proportions
    @amounts_by_category = Hash[Subscription.all.select("category, SUM(amount) AS total").group(:category)
                                    .map {|s| [s.category, s.total]}]
    render json: @amounts_by_category
  end

  def regions
    @amounts_by_region = Hash[Subscription.all.select("region, SUM(amount) AS total").group(:region)
                                    .map {|s| [s.region, s.total]}]
    render json: @amounts_by_region
  end

  private

  def subscription_params
    params.require(:subscription).permit!
  end
end
