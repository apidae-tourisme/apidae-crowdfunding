class Subscription < ApplicationRecord
  include AASM

  has_one_attached :signature
  has_many :sponsored, class_name: "Subscription", foreign_key: :sponsor_id
  belongs_to :sponsor, class_name: "Subscription", optional: true

  store_accessor :structure_data, :structure_name, :siret, :ape, :legal_type, :legal_type_desc, :apidae_member_id, :widget_hosts
  store_accessor :person_data, :title, :first_name, :last_name, :role, :birth_date, :address, :postal_code, :town, :country,
                 :telephone, :email, :website, :fund_deposit, :payment_method, :signing, :ack_societaire, :ack_statuts,
                 :ack_biens_communs, :ack_convocation, :person_type

  attr_accessor :signature_data

  before_save :compute_fields

  aasm column: 'status' do
    state :declared, initial: true
    state :confirmed

    event :confirm do
      transitions from: :declared, to: :confirmed
    end
  end

  def self.by_subscriber
    Subscription.all.group("person_data -> 'email', category, label")
        .select("MIN(id) AS sub_id, MIN(created_at) AS creation_date, category, label, SUM(amount) AS total")
  end

  def shares_count
    amount.nil? ? 0 : (amount / 100).to_i
  end

  def amount_as_text
    "#{amount.humanize} euros" unless amount.nil?
  end

  def is_structure?
    category != 'sa' && category != 'sr'
  end

  def pp?
    person_type == 'pp'
  end

  def document_filename
    "Bulletin souscription - #{pp? ? 'Personne physique' : 'Personne morale'} - #{public_label} - #{signed_at ? (I18n.l(signed_at, format: :doc) + ' - Signé') : 'Non signé'}"
  end

  def compute_fields
    self.label = normalize_label
    unless postal_code.blank?
      code = country == 'fr' ? lpad(postal_code) : (country.upcase + postal_code)
      REGIONS.each_pair do |r, codes|
        self.region = r if codes.any? {|c| code.start_with?(c)}
      end
    end
  end

  def normalize_label
    if com_enabled
      public_label
    else
      'Déclaration anonyme'
    end
  end

  def public_label
    is_structure? ? structure_name.gsub(/office (de|du) tourisme/i, 'OT') : full_name
  end

  def full_name
    "#{title} #{first_name} #{last_name}"
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
