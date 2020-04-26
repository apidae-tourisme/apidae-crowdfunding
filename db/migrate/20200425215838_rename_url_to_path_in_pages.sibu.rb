# This migration comes from sibu (originally 20180126114522)
class RenameUrlToPathInPages < ActiveRecord::Migration[5.1]
  def change
    rename_column :sibu_pages, :url, :path
  end
end
