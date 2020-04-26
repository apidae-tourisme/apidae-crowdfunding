# This migration comes from sibu (originally 20180208125024)
class RenameImageDataColumn < ActiveRecord::Migration[5.1]
  def change
    rename_column :sibu_images, :data, :file_data
  end
end
