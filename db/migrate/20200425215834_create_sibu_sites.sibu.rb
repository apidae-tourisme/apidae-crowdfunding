# This migration comes from sibu (originally 20180124095041)
class CreateSibuSites < ActiveRecord::Migration[5.1]
  def change
    create_table :sibu_sites do |t|
      t.string :name
      t.integer :site_template_id
      t.text :metadata
      t.jsonb :sections

      t.timestamps
    end
  end
end
