class StaticController < ApplicationController
  def temp
    render 'temp', layout: false
  end

  def home
  end

  def fonts
  end
end
