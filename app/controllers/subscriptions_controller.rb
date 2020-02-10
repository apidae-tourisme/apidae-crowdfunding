require "base64"

class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:update, :share, :widget, :show, :confirm, :document]
  skip_before_action :verify_authenticity_token, only: [:show]

  def index
    @subscriptions = Subscription.by_subscriber
  end

  def new
    @subscription = Subscription.new
  end

  def create
    @subscription = Subscription.new(subscription_params)
    if @subscription.signature_data
      encoded_signature = @subscription.signature_data.split(",")[1]
      decoded_signature = Base64.decode64(encoded_signature)
      @subscription.signature.attach(io: StringIO.new(decoded_signature), filename: 'signature.png')
    end
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
    @subscriptions = filtered_records(Subscription.by_subscriber).order("total DESC, sub_id ASC").limit(5)
  end

  def proportions
    default_map = Hash[CATEGORIES.keys.map {|cat| [cat.to_s, 0]}]
    records = (params[:filter].blank? || CATEGORIES.keys.include?(params[:filter].to_sym)) ? Subscription.by_subscriber : filtered_records(Subscription.by_subscriber)
    @members_by_category = default_map.merge(Hash[records.to_a.group_by {|s| s.category }.map {|cat, subs| [cat, subs.length]}])
    @amount_by_category = default_map.merge(Hash[records.to_a.group_by {|s| s.category }.map {|cat, subs| [cat, subs.sum {|s| s.total}]}])
    render json: {subscriptions: @members_by_category, amounts: @amount_by_category}
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

  def document
    render :document, layout: 'print'
  end

  private

  def subscription_params
    params.require(:subscription).permit!
  end

  def set_subscription
    @subscription = Subscription.find(params[:id])
  end

  def filtered_records(records)
    unless params[:filter].blank?
      filter_type = CATEGORIES.keys.include?(params[:filter].to_sym) ? 'category' : 'region'
      records = records.where("#{filter_type} = ?", params[:filter])
    end
    records
  end
end
