module SubscriptionsHelper
  def subscription_categories
    CATEGORIES.map {|ref, cat| [cat[:name], ref.to_s]}
  end

  def subscription_countries
    [
        ['France', 'fr'],
        ['Suisse', 'ch'],
        ['Allemagne', 'de'],
        ['Italie', 'it'],
        ['Espagne', 'es'],
        ['Belgique', 'be'],
        ['Royaume-Uni', 'uk']
    ]
  end

  def subscription_titles
    ['M.', 'Mme']
  end

  def legal_types
    LEGAL_TYPES.map {|ref, label| [label, ref.to_s]}
  end

  def subscription_sponsors
    Subscription.where(com_enabled: true).by_subscriber.to_a.sort_by {|s| s.label}.map {|s| [s.label, s.sub_id]}
  end

  def deposit_choices
    [
        ['Avant le 16/03/2020', 'before'],
        ['Après le 16/03/2020', 'after'],
        ['Ne sait pas', 'unavailable']
    ]
  end

  def chk(field, checked_value)
    "<i class=\"u-big apidae-icon-#{@subscription.send(field) == checked_value ? 'validate' : 'hexa'}\"></i>".html_safe
  end

  def address_fields
    @subscription.address.split(/(\r\n?)/)
  end

  def phase_label
    @subscription.persisted? && @subscription.declared? ? "souscription" : "déclaration d'intention"
  end
end
