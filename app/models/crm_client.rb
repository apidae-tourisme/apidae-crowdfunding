require 'sellsy'
require 'open-uri'

class CrmClient
  def self.lookup_entity(subscription)
    if !subscription.apidae_member_id.blank?
      search_params = {'ident' => subscription.apidae_member_id}
    else
      search_params = subscription.pp? ? {'type' => 'person', 'contains' => subscription.email} :
                          {'type' => 'corporation', 'containssiret' => subscription.siret}
    end

    customers = Sellsy::Customer.search({'search' => search_params})
    customers.first || lookup_prospect(subscription)
  end

  def self.lookup_prospect(subscription)
    prospects = Sellsy::Prospect.search({'search' => {'contains' => subscription.email}})
    prospects.first
  end

  def self.name_field(subscription)
    (subscription.pp? ? subscription.last_name : subscription.structure_name).parameterize
  end

  def self.add_or_update(subscription)
    history_entry = {}
    entity = lookup_entity(subscription)

    if entity
      entity_ref = entity.is_a?(Sellsy::Prospect) ? 'prospect' : 'customer'
      update_entity(entity, entity_ref, subscription, history_entry)
    else
      entity_ref = 'prospect'
      entity = create_prospect(subscription, history_entry)
      history_entry['prospect_create'] = entity.id
      unless subscription.is_rep?
        rep_contact = init_rep_contact(subscription, entity.id)
        history_entry['rep_contact_create'] = rep_contact.create ? rep_contact.id : false
        if rep_contact.id
          history_entry["rep_contact_custom_fields"] =
              Sellsy::CustomField.set_values(rep_contact, Sellsy::CustomField.new(*lookup_value(SELLSY_REFERENT_SOCIETAIRE, ['INST'])))
        end
      end
    end

    history_entry["#{entity_ref}_custom_fields"] =
        Sellsy::CustomField.set_values(entity,
                                       Sellsy::CustomField.new(*lookup_value(SELLSY_TYPE_COLLEGE, college_type(subscription))),
                                       Sellsy::CustomField.new(*lookup_value(SELLSY_CATEGORIE_SOCIETAIRE, category(subscription))),
                                       subscription.pp? ? nil : Sellsy::CustomField.new(*lookup_value(SELLSY_STATUT_JURIDIQUE, LEGAL_TYPES[subscription.legal_type.to_sym][:crm_code])),
                                       subscription.pp? ? nil : Sellsy::CustomField.new(*lookup_value(SELLSY_SECTEUR_ACTIVITE, activity_domain(subscription)))
        )

    entity_contact = (entity.class.to_s.constantize).find(entity.id)
    unless entity_contact.contacts.blank?
      contact = Sellsy::Contact.new
      contact.id = entity_contact.contacts.values.first['peopleid']
      history_entry["contact_custom_fields"] =
          Sellsy::CustomField.set_values(contact, Sellsy::CustomField.new(*lookup_value(SELLSY_REFERENT_SOCIETAIRE, rep_values(subscription))))
    end

    opportunity = add_or_update_opportunity(entity, subscription, history_entry, (entity_contact.contacts || {}).keys)

    subscription.crm_history ||= {}
    subscription.crm_history[Time.current.to_i] = history_entry
    subscription.opportunity_id = opportunity.id

    subscription.save
  end

  def self.create_prospect(subscription, history_entry)
    prospect = Sellsy::Prospect.new
    contact = Sellsy::Contact.search(subscription.first_name + ' ' + subscription.last_name, subscription.birth_date).first
    populate_fields(prospect, subscription, contact || Sellsy::Contact.new)
    prospect.create
    if contact && prospect.id
      unless contact.third_ids.include?(prospect.id)
        contact.third_ids += [prospect.id]
      end
      history_entry["contact_update"] = contact.update
    end
    prospect
  end

  def self.update_entity(entity, entity_ref, subscription, history_entry)
    contact = Sellsy::Contact.search(subscription.first_name + ' ' + subscription.last_name, subscription.birth_date).first
    populate_fields(entity, subscription, contact || Sellsy::Contact.new)
    result = entity.update
    history_entry["#{entity_ref}_update"] = result ? entity.id : false
    if contact
      unless contact.third_ids.include?(entity.id)
        contact.third_ids += [entity.id]
      end
      history_entry["contact_update"] = contact.update
    end
    result
  end

  def self.add_or_update_opportunity(entity, subscription, history_entry, contacts_ids)
    if subscription.opportunity_id
      opportunity = Sellsy::Opportunity.find(subscription.opportunity_id)
    else
      opportunity = Sellsy::Opportunity.new
    end

    opportunity.name = "Souscription #{subscription.id} - Personne #{subscription.pp? ? 'physique' : 'morale'}"
    opportunity.reference = "SOUSCRIPTION-#{subscription.id}"
    opportunity.amount = subscription.amount
    opportunity.entity_type = entity.is_a?(Sellsy::Customer) ? 'third' : 'prospect'
    opportunity.entity_id = entity.id
    opportunity.source_name = "Site web"
    opportunity.funnel_name = "Souscription Scic"
    opportunity.step_name = subscription.signed_at ? "Bulletin signé" : "Bulletin renseigné"
    opportunity.comments = subscription.comments
    opportunity.contacts = contacts_ids

    result = subscription.opportunity_id ? opportunity.update : opportunity.create
    history_entry["opportunity_#{subscription.opportunity_id ? 'update' : 'create'}"] = result ? opportunity.id : false

    if result
      result = Sellsy::CustomField.set_values(opportunity,
                                              Sellsy::CustomField.new(lookup_field(SELLSY_NB_PARTS), subscription.shares_count),
                                              Sellsy::CustomField.new(lookup_field(SELLSY_NUM_SOUSCRIPTION), subscription.id),
                                              subscription.payment_method ? Sellsy::CustomField.new(*lookup_value(SELLSY_MOYEN_PAIEMENT, payment_method_code(subscription))) : nil,
                                              Sellsy::CustomField.new(*lookup_value(SELLSY_LIBERATION_MONTANT, subscription.payments_count == 'half_payment' ? "2" : "1"))
      )
      history_entry["opportunity_custom_fields"] = result

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
        history_entry["opportunity_attachment"] = attachment.create
      end
    end
    opportunity
  end

  def self.init_rep_contact(subscription, entity_id)
    contact = Sellsy::Contact.new
    [:rep_title, :rep_first_name, :rep_last_name, :rep_role, :rep_telephone, :rep_email].each do |field|
      contact.send("#{field.to_s.gsub('rep_', '')}=", subscription.send(field))
    end
    contact.third_ids = [entity_id]
    contact
  end

  def self.populate_fields(entity, subscription, contact)
    [:title, :first_name, :last_name, :role, :birth_date, :telephone, :email, :website].each do |field|
      contact.send("#{field}=", subscription.send(field))
    end
    address = Sellsy::Address.new
    [:address, :postal_code, :town, :country].each do |field|
      address.send("#{field}=", subscription.send(field))
    end
    tmp_contact = Sellsy::Contact.new
    tmp_contact.name = contact.last_name
    entity.name = subscription.public_label
    entity.contact = contact.id ? tmp_contact : contact
    entity.address = address
    entity.legal_type = LEGAL_TYPES[subscription.legal_type.to_sym][:crm_code] unless subscription.pp?
    [:structure_name, :category, :siret, :ape, :email, :website, :payment_method, :person_type].each do |field|
      entity.send("#{field}=", subscription.send(field))
    end
  end

  def self.college_type(subscription)
    CATEGORIES[subscription.category.to_sym][:college_code] unless
        subscription.category.blank? || CATEGORIES[subscription.category.to_sym].blank?
  end

  def self.category(subscription)
    CATEGORIES[subscription.category.to_sym][:category_code] unless
        subscription.category.blank? || CATEGORIES[subscription.category.to_sym].blank?
  end

  def self.activity_domain(subscription)
    case subscription.legal_type
    when 'association', 'eurl', 'sa', 'sarl', 'sas', 'sem', 'cooperative'
      'PRI'
    when 'collectivite_territoriale', 'regie_autonome', 'epic', 'spa', 'spic', 'regie_simple'
      'PUB'
    when 'autre'
      '??'
    else
      '??'
    end
  end

  def self.rep_values(subscription)
    subscription.is_rep? ? ['LEG', 'INST'] : ['LEG']
  end

  def self.payment_method_code(subscription)
    if subscription.payment_method == 'cheque'
      'CH'
    elsif subscription.payment_method == 'virement'
      'VIR'
    else
      nil
    end
  end

  def self.lookup_field(field_code)
    SELLSY_CUSTOM_FIELDS[field_code][:id] unless SELLSY_CUSTOM_FIELDS[field_code].blank?
  end

  def self.lookup_value(field_code, value_code)
    field_val = []
    if SELLSY_CUSTOM_FIELDS.keys.include?(field_code)
      if value_code.is_a?(Array)
        value = SELLSY_CUSTOM_FIELDS[field_code][:values].select {|v| value_code.include?(v[:value].split(' - ').first)}
      else
        value = SELLSY_CUSTOM_FIELDS[field_code][:values].find {|v| v[:value].split(' - ').first == value_code}
      end
      if value
        field_val = value.is_a?(Array) ? [value.first[:cfid], value.map {|v| v[:value]}] : [value[:cfid], value[:value]]
      end
    end
    field_val
  end
end
