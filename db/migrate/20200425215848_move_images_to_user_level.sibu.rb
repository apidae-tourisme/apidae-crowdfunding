# This migration comes from sibu (originally 20180321144021)
class MoveImagesToUserLevel < ActiveRecord::Migration[5.1]
  def change
    add_column :sibu_images, :user_id, :integer
    Sibu::Image.where("site_id IS NOT NULL").each {|img| img.update(user_id: Sibu::Site.find(img.site_id).user_id)}
    remove_column :sibu_images, :site_id
  end
end
