class CreateApidaeMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :apidae_members do |t|
      t.integer :apidae_id
      t.string :name
      t.integer :legal_entity_id

      t.timestamps
    end
  end
end
