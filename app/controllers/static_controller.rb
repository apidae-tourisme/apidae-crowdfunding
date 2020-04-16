class StaticController < ApplicationController
  def temp
    render 'temp', layout: false
  end

  def home
    @total = Subscription.sum(:amount).to_i
    @count = Subscription.count
  end

  def fonts
  end

  def legal
  end

  def contact
  end

  def territories
  end

  def companies
  end

  def supporters
  end

  def howto
  end

  def faq
  end
end
