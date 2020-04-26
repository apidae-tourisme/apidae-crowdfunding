# This migration comes from sibu (originally 20180301152101)
class AddDefaultStylesToTemplates < ActiveRecord::Migration[5.1]
  def change
    add_column :sibu_site_templates, :default_styles, :text
  end
end
