class Subscription < ApplicationRecord
  has_many :sponsored, class_name: "Subscription", foreign_key: :sponsor_id
  belongs_to :sponsor, class_name: "Subscription", optional: true

  store_accessor :structure_data, :structure_name, :siret, :legal_type, :legal_type_desc, :apidae_member_id
  store_accessor :person_data, :title, :first_name, :last_name, :role, :address, :postal_code, :town, :country,
                 :telephone, :email, :website, :fund_deposit

  before_save :compute_fields

  def is_structure?
    category != 'sa' && category != 'sr'
  end

  def compute_fields
    self.label = is_structure? ? structure_name : "#{title} #{first_name} #{last_name}"
    code = country == 'ch' ? ('CH' + postal_code) : lpad(postal_code)
    REGIONS.each_pair do |r, codes|
      self.region = r if codes.any? {|c| code.start_with?(c)}
    end
  end

  def lpad(str)
    str.length == 5 ? str : ('0' + str)
  end
end
