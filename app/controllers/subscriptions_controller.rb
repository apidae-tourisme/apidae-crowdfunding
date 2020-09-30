require "base64"

class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:edit, :update, :share, :widget, :update_widget, :show, :confirm, :document]
  skip_before_action :verify_authenticity_token, only: [:show]

  def index
    @subscriptions = Subscription.all.by_subscriber
  end

  def new
    @subscription = Subscription.new(person_type: 'pm', payments_count: 'single_payment', is_rep: "1")
  end

  def create
    @subscription = Subscription.new(subscription_params)
    handle_subscription_save(true, :new)
  end

  def edit
    if @subscription.confirmed?
      redirect_to url_for(action: :confirm)
    else
      @subscription.person_type ||= 'pm'
      @subscription.payments_count ||= 'single_payment'
    end
  end

  def update
    @subscription.attributes = subscription_params
    handle_subscription_save(false, :edit)
  end

  def update_widget
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

  def member
    @member = ApidaeMember.find_by_apidae_id(params[:id])
    render json: @member.retrieve_info.merge(id: @member.apidae_id, name: @member.name)
  end

  def confirm
  end

  def rankings
    @subscriptions = filtered_records(Subscription.all.by_subscriber).order("total DESC, sub_id ASC").limit(5)
    @max_amount = @subscriptions.to_a.map {|s| s.total}.max
  end

  def proportions
    default_map = Hash[CATEGORIES.keys.map {|cat| [cat.to_s, 0]}]
    records = (params[:filter].blank? || CATEGORIES.keys.include?(params[:filter].to_sym)) ? Subscription.all.by_subscriber : filtered_records(Subscription.by_subscriber)
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
    @subscription = Subscription.find(Subscription.decrypt(params[:id]))
  end

  def filtered_records(records)
    unless params[:filter].blank?
      filter_type = CATEGORIES.keys.include?(params[:filter].to_sym) ? 'category' : 'region'
      records = records.where("#{filter_type} = ?", params[:filter])
    end
    records
  end

  def handle_subscription_save(new_sub, error_action)
    unless @subscription.signature_data.blank?
      encoded_signature = @subscription.signature_data.split(",")[1]
      unless encoded_signature.blank?
        decoded_signature = Base64.decode64(encoded_signature)
        @subscription.signature.attach(io: StringIO.new(decoded_signature), filename: 'signature.png')
      end
    end
    if @subscription.save
      if new_sub
        SubscriptionsMailer.declare_subscription(@subscription).deliver_now
        redirect_to confirm_subscription_url(@subscription)
      elsif @subscription.confirm!
        SubscriptionsMailer.confirm_subscription(@subscription).deliver_now
        redirect_to confirm_subscription_url(@subscription)
      else
        flash.now[:alert] = "Une erreur s'est produite lors de la confirmation de la souscription."
        render error_action
      end
    else
      flash.now[:alert] = "Une erreur s'est produite lors de l'enregistrement de la souscription."
      render error_action
    end
  end
end
