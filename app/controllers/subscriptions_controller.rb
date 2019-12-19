class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:update, :share, :widget, :show, :confirm]
  skip_before_action :verify_authenticity_token, only: [:show]

  def index
    @subscriptions = Subscription.all.select(:label, :amount, :category)
  end

  def new
    @subscription = Subscription.new
  end

  def create
    @subscription = Subscription.new(subscription_params)
    if @subscription.save
      SubscriptionsMailer.confirm_subscription(@subscription).deliver_now
      redirect_to confirm_subscription_url(@subscription)
    else
      flash.now[:alert] = "Une erreur s'est produite lors de l'enregistrement de la déclaration."
      render :new
    end
  end

  def update
    unless params[:subscription][:widget_hosts].blank?
      hosts = params[:subscription][:widget_hosts].split(',').map {|h| h.strip.gsub(/https?:\/\//, '')}
      @success = @subscription.update(widget_hosts: hosts)
    end
  end

  def show
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
    @subscriptions = filtered_records.select("label, LOG(amount) AS value, amount, category").order("value DESC").limit(5)
  end

  def proportions
    default_map = Hash[CATEGORIES.keys.map {|cat| [cat.to_s, 0]}]
    records = (params[:filter].blank? || CATEGORIES.keys.include?(params[:filter].to_sym)) ? Subscription.all : filtered_records
    @subscriptions_by_category = default_map.merge(Hash[records.select("category, COUNT(id) AS subs").group(:category)
                                          .map {|s| [s.category, s.subs]}])
    @amount_by_category = default_map.merge(Hash[records.select("category, SUM(amount) AS total").group(:category)
                                   .map {|s| [s.category, s.total]}])
    render json: {subscriptions: @subscriptions_by_category, amounts: @amount_by_category}
  end

  def regions
    @amounts_by_region = Hash[Subscription.all.select("region, SUM(amount) AS total").group(:region)
                                    .map {|s| [s.region, s.total]}]
    render json: @amounts_by_region
  end

  def share
    render :share, layout: 'standalone'
  end

  def widget
  end

  private

  def subscription_params
    params.require(:subscription).permit!
  end

  def set_subscription
    @subscription = Subscription.find(params[:id])
  end

  def filtered_records
    records = Subscription.all
    unless params[:filter].blank?
      filter_type = CATEGORIES.keys.include?(params[:filter].to_sym) ? 'category' : 'region'
      records = records.where("#{filter_type} = ?", params[:filter])
    end
    records
  end
end
