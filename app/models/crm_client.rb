require 'sellsy'
require 'open-uri'

class CrmClient

  LEGAL_TYPES = {
      association: "Association",
      eurl: "Entreprise Unipersonnelle à Responsabilité Limitée (EURL)",
      regie_autonome: "Régie autonome",
      epic: "Régie personnalisée gestionnaire d’un Établissement Public Industriel et Commercial (EPIC)",
      spa: "Régie personnalisée gestionnaire d'un Service Public Administratif (SPA)",
      spic: "Régie personnalisée gestionnaire d'un Service Public Industriel et Commercial (SPIC)",
      regie_simple: "Régie simple (régie directe)",
      sa: "Société Anonyme (SA)",
      sarl: "Société à Responsabilité Limitée (SARL)",
      sas: "Société par Actions Simplifiée (SAS)",
      sem: "Société d'Economie Mixte (SEM)"
  }

  def self.lookup_entity(subscription)
    if subscription.apidae_member_id
      search_params = {'ident' => subscription.apidae_member_id}
    else
      search_params = subscription.pp? ? {'type' => 'person', 'contains' => subscription.email} :
                          {'type' => 'corporation', 'containssiret' => subscription.siret}
    end

    customers = Sellsy::Customer.search({'search' => search_params})
    if customers.blank?
      entity = lookup_prospect(subscription)
    elsif customers.length == 1
      entity = customers.first
    else
      entity = customers.find {|c| c.name.parameterize.include?(name_field(subscription))}
    end
    entity
  end

  def self.lookup_prospect(subscription)
    prospects = Sellsy::Prospect.search({'contains' => subscription.email})
    if prospects.blank?
    elsif prospects.length == 1
      prospects.first
    else
      prospects.find {|p| p.name.parameterize.include?(name_field(subscription))}
    end
  end

  def self.name_field(subscription)
    (subscription.pp? ? subscription.last_name : subscription.structure_name).parameterize
  end

  def self.add_or_update(subscription)
    Sellsy::Api.configure do |config|
      config.consumer_token = Rails.application.config.sellsy_consumer_token
      config.consumer_secret = Rails.application.config.sellsy_consumer_secret
      config.user_token = Rails.application.config.sellsy_user_token
      config.user_secret = Rails.application.config.sellsy_user_secret
    end

    entity = lookup_entity(subscription)

    if entity
      update_entity(entity, subscription)
    else
      entity = create_prospect(subscription)
    end

    Sellsy::CustomField.set_values(entity,
                                   Sellsy::CustomField.new('88153', college_type(subscription)),
                                   Sellsy::CustomField.new('88155', LEGAL_TYPES[subscription.legal_type]),
                                   Sellsy::CustomField.new('88156', activity_domain(subscription))
    )

    contact_id = (entity.class.to_s.constantize).find(entity.id).main_contact_id
    unless contact_id.blank?
      contact = Sellsy::Contact.new
      contact.id = contact_id
      Sellsy::CustomField.set_values(contact, Sellsy::CustomField.new('88160', 'Oui'))
    end

    opportunity = add_opportunity(entity, subscription)

    subscription.update(opportunity_id: opportunity.id)
  end

  def self.create_prospect(subscription)
    prospect = Sellsy::Prospect.new
    populate_fields(prospect, subscription)
    prospect.create
    prospect
  end

  def self.update_entity(entity, subscription)
    populate_fields(entity, subscription)
    entity.update
  end

  def self.add_opportunity(entity, subscription)
    result = true

    opportunity = Sellsy::Opportunity.new
    opportunity.name = "Souscription #{subscription.id} - Personne #{subscription.pp? ? 'physique' : 'morale'}"
    opportunity.reference = "SOUSCRIPTION-#{subscription.id}"
    opportunity.amount = subscription.amount
    opportunity.entity_type = entity.is_a?(Sellsy::Customer) ? 'third' : 'prospect'
    opportunity.entity_id = entity.id
    opportunity.source_name = "Site web"
    opportunity.funnel_name = "Souscription Scic"
    opportunity.step_name = subscription.signed_at ? "Bulletin signé" : "Bulletin renseigné"
    opportunity.comments = subscription.comments
    opportunity.create

    if opportunity.id
      result = Sellsy::CustomField.set_values(opportunity,
                                     Sellsy::CustomField.new('88161', subscription.shares_count),
                                     Sellsy::CustomField.new('88162', subscription.id),
                                     Sellsy::CustomField.new('88163', I18n.t("export.subscription.value.#{subscription.payment_method}")),
                                     Sellsy::CustomField.new('88166', (subscription.payments_count == 'half_payment' ? "Deux fois (50%)" : "Une fois"))
      )

      if result
        file_url = "https://print.souscription.apidae-tourisme.com/souscription?path=" +
            CGI.escape(Rails.application.routes.url_helpers.document_subscription_url(subscription, protocol: 'https'))
        local_path = Rails.root.join('tmp', "#{subscription.document_filename}.pdf")
        download = open(file_url)
        IO.copy_stream(download, local_path)
        attachment = Sellsy::Attachment.new
        attachment.entity_type = 'opportunity'
        attachment.entity_id = opportunity.id
        attachment.file = File.open(local_path)
        attachment.create
      end
    end
    opportunity
  end

  def self.populate_fields(entity, subscription)
    entity.name = subscription.public_label
    [:title, :first_name, :last_name, :structure_name, :category, :siret, :ape, :legal_type, :role, :birth_date,
     :address, :postal_code, :town, :country, :telephone, :email, :website, :payment_method, :person_type].each do |field|
      entity.send("#{field}=", subscription.send(field))
    end
  end

  def self.college_type(subscription)
    case subscription.category
    when 'mo'
      "Collège A - Garants de l’économie territoriale"
    when 'sa'
      "Collège B - Salariés"
    when 'at', 'ct'
      "Collège C - Acteurs territoriaux"
    when 'fs'
      "Collège D - Fournisseurs de service"
    when 'sp', 'sr'
      "Collège E - Socio-professionnels et soutiens"
    else
      nil
    end
  end

  def self.activity_domain(subscription)
    case subscription.legal_type
    when 'association', 'eurl', 'sa', 'sarl', 'sas', 'sem', 'cooperative'
      'Privé'
    when 'collectivite_territoriale', 'regie_autonome', 'epic', 'spa', 'spic', 'regie_simple'
      'Public'
    when 'autre'
    else
      'A vérifier'
    end
  end
end
