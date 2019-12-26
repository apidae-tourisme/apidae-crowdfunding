class Admin::UserController < ApplicationController
  layout 'admin'

  def after_sign_in_path_for(resource)
    subs_path
  end
end