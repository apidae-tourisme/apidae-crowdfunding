require 'sellsy'

class Subscription < ApplicationRecord
  include AASM
  include Obfuscable

  has_one_attached :signature
  has_many :sponsored, class_name: "Subscription", foreign_key: :sponsor_id
  belongs_to :sponsor, class_name: "Subscription", optional: true

  store_accessor :structure_data, :structure_name, :siret, :ape, :legal_type, :legal_type_desc, :apidae_member_id, :widget_hosts
  store_accessor :person_data, :title, :first_name, :last_name, :role, :birth_date, :address, :postal_code, :town, :country,
                 :telephone, :email, :website, :is_rep, :rep_title, :rep_first_name, :rep_last_name, :rep_role, :rep_telephone, :rep_email,
                 :fund_deposit, :payment_method, :payments_count, :signing,
                 :ack_societaire, :ack_statuts, :ack_biens_communs, :ack_convocation, :person_type
  store_accessor :crm_data, :opportunity_id, :crm_history

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
    group("person_data -> 'email', category, label")
        .select("MIN(id) AS sub_id, MIN(created_at) AS creation_date, category, label, SUM(amount) AS total")
  end

  def to_param
    encrypt id
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

  def is_rep?
    is_rep == '1'
  end

  def email_recipient
    (!is_rep? && !rep_email.blank?) ? rep_email : email
  end

  def document_filename
    "Bulletin souscription - #{id} - #{pp? ? 'Personne physique' : 'Personne morale'} - #{public_label} - #{signed_at ? (I18n.l(signed_at, format: :doc) + ' - Signé') : 'Non signé'}".gsub('/', '-')
  end

  def compute_fields
    self.normalize_names
    self.label = normalize_label
    unless postal_code.blank?
      self.postal_code = postal_code.strip
      code = country == 'fr' ? lpad(postal_code) : (country.upcase + postal_code)
      REGIONS.each_pair do |r, codes|
        self.region = r if codes.any? {|c| code.start_with?(c)}
      end
    end
    self.is_rep = '1' if is_rep.nil?
    self.siret = normalize_siret
  end

  def normalize_siret
    siret.gsub(/\s/, '') unless siret.blank?
  end

  def normalize_label
    if com_enabled
      public_label
    else
      'Déclaration anonyme'
    end
  end

  def normalize_names
    [:first_name, :last_name, :rep_first_name, :rep_last_name].each do |n|
      self.send("#{n}=", normalize_name(send(n))) unless send(n).blank?
    end
  end

  def normalize_name(txt)
    txt.split('-').map {|t| t.capitalize}.join('-')
  end

  def public_label
    is_structure? ? structure_name.gsub(/office (de|du) tourisme/i, 'OT') : full_name
  end

  def full_name
    "#{title} #{first_name} #{last_name}"
  end

  def full_rep_name
    "#{rep_title} #{rep_first_name} #{rep_last_name}"
  end

  def emails
    [email, rep_email].select {|e| !e.blank?}
  end

  def lpad(str)
    str.length == 5 ? str : ('0' + str)
  end

  def legal_entity_type
    (legal_type == 'autre' ? legal_type_desc : LEGAL_TYPES[legal_type.to_sym][:label]) unless legal_type.blank?
  end

  def sponsor_label
    sponsor.label if sponsor
  end

  def last_crm_entry
    unless crm_history.blank?
      {timestamp: crm_history.keys.sort.last, statuses: crm_history[crm_history.keys.sort.last]}
    end
  end

  def opportunity_link
    "https://www.sellsy.fr/prospection/opportunities/#{opportunity_id}" unless opportunity_id.blank?
  end
end
