# This migration comes from sibu (originally 20180214134653)
class AddFieldsToSites < ActiveRecord::Migration[5.1]
  def change
    add_column :sibu_sites, :custom_data, :text
  end
end
