# This migration comes from sibu (originally 20180210181644)
class AddDefaultsToSiteTemplates < ActiveRecord::Migration[5.1]
  def change
    add_column :sibu_site_templates, :default_sections, :text
    add_column :sibu_site_templates, :default_pages, :text
  end
end
