class Subscription < ApplicationRecord
  store_accessor :structure_data, :structure_name, :siret, :legal_type, :apidae_member_id
  store_accessor :person_data, :title, :first_name, :last_name, :role, :address, :postal_code, :town, :telephone, :email
end
