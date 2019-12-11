class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.string :category
      t.float :amount
      t.text :comments
      t.jsonb :structure_data
      t.jsonb :person_data
      t.boolean :com_enabled

      t.timestamps
    end
  end
end
