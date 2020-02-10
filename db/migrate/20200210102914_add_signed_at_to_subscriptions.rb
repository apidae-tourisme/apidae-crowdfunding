class AddSignedAtToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :signed_at, :datetime
  end
end
