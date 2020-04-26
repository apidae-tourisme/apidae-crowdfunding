# This migration comes from sibu (originally 20180405095448)
class CreateSibuDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :sibu_documents do |t|
      t.integer :user_id
      t.text :file_data

      t.timestamps
    end
  end
end
