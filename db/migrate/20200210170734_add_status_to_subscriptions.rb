class AddStatusToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :status, :string
    Subscription.update_all(status: 'declared')
  end
end
