class Subscription < ApplicationRecord
  has_many :sponsored, class_name: "Subscription", foreign_key: :sponsor_id
  belongs_to :sponsor, class_name: "Subscription", optional: true

  store_accessor :structure_data, :structure_name, :siret, :legal_type, :legal_type_desc, :apidae_member_id, :widget_hosts
  store_accessor :person_data, :title, :first_name, :last_name, :role, :address, :postal_code, :town, :country,
                 :telephone, :email, :website, :fund_deposit

  before_save :compute_fields

  def self.by_subscriber
    Subscription.all.group("person_data -> 'email', category, label")
        .select("MIN(id) AS sub_id, MIN(created_at) AS creation_date, category, label, SUM(amount) AS total")
  end

  def is_structure?
    category != 'sa' && category != 'sr'
  end

  def compute_fields
    self.label = normalize_label
    unless postal_code.blank?
      code = country == 'ch' ? ('CH' + postal_code) : lpad(postal_code)
      REGIONS.each_pair do |r, codes|
        self.region = r if codes.any? {|c| code.start_with?(c)}
      end
    end
  end

  def normalize_label
    if com_enabled
      is_structure? ? structure_name.gsub(/office (de|du) tourisme/i, 'OT') : "#{title} #{first_name} #{last_name}"
    else
      'Déclaration anonyme'
    end
  end

  def lpad(str)
    str.length == 5 ? str : ('0' + str)
  end

  def legal_entity_type
    (legal_type == 'autre' ? legal_type_desc : LEGAL_TYPES[legal_type.to_sym]) unless legal_type.blank?
  end

  def sponsor_label
    sponsor.label if sponsor
  end
end
