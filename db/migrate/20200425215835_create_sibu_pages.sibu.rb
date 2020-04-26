# This migration comes from sibu (originally 20180124095213)
class CreateSibuPages < ActiveRecord::Migration[5.1]
  def change
    create_table :sibu_pages do |t|
      t.string :name
      t.integer :site_id
      t.text :metadata
      t.string :language
      t.string :url
      t.string :template
      t.jsonb :sections

      t.timestamps
    end
  end
end
