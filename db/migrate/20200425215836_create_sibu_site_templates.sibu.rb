# This migration comes from sibu (originally 20180124145030)
class CreateSibuSiteTemplates < ActiveRecord::Migration[5.1]
  def change
    create_table :sibu_site_templates do |t|
      t.string :name
      t.string :path

      t.timestamps
    end
  end
end
