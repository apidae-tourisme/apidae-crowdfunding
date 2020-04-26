# This migration comes from sibu (originally 20180321170310)
class AddVersionToSibuSites < ActiveRecord::Migration[5.1]
  def change
    add_column :sibu_sites, :version, :string
    Sibu::Site.update_all(version: 'fr')
    remove_column :sibu_pages, :language
  end
end
