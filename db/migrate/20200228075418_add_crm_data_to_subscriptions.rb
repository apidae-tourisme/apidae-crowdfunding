class AddCrmDataToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :crm_data, :jsonb
  end
end
