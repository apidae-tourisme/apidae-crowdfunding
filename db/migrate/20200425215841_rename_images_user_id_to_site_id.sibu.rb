# This migration comes from sibu (originally 20180208082317)
class RenameImagesUserIdToSiteId < ActiveRecord::Migration[5.1]
  def change
    rename_column :sibu_images, :user_id, :site_id
  end
end
