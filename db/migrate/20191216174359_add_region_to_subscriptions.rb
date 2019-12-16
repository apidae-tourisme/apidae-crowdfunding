class AddRegionToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :region, :string
  end
end
