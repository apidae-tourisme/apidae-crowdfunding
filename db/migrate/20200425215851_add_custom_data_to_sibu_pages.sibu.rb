# This migration comes from sibu (originally 20190110204854)
class AddCustomDataToSibuPages < ActiveRecord::Migration[5.1]
  def change
    add_column :sibu_pages, :custom_data, :text
  end
end
