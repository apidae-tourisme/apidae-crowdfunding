class Admin::SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def export
  end
end
