class Subscription < ApplicationRecord
  has_many :sponsored, class_name: "Subscription", foreign_key: :sponsor_id
  belongs_to :sponsor, class_name: "Subscription", optional: true

  store_accessor :structure_data, :structure_name, :siret, :legal_type, :legal_type_desc, :apidae_member_id
  store_accessor :person_data, :title, :first_name, :last_name, :role, :address, :postal_code, :town, :country,
                 :telephone, :email, :website

  def label
    is_structure? ? structure_name : "#{title} #{first_name} #{last_name}"
  end

  def is_structure?
    category != 'sa' && category != 'sr'
  end
end
