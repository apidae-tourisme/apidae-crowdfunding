class AddLabelToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :label, :string
  end
end
