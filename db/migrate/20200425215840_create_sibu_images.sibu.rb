# This migration comes from sibu (originally 20180127211533)
class CreateSibuImages < ActiveRecord::Migration[5.1]
  def change
    create_table :sibu_images do |t|
      t.integer :user_id
      t.text :metadata
      t.text :data

      t.timestamps
    end
  end
end
