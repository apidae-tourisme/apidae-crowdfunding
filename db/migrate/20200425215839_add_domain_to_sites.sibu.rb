# This migration comes from sibu (originally 20180126114628)
class AddDomainToSites < ActiveRecord::Migration[5.1]
  def change
    add_column :sibu_sites, :domain, :string
  end
end
