module SubscriptionsHelper
  def subscription_categories
    CATEGORIES.map {|ref, cat| [cat[:name], ref.to_s]}
  end

  def subscription_countries
    [
        ['France', 'fr'],
        ['Suisse', 'ch']
    ]
  end

  def subscription_titles
    ['M.', 'Mme']
  end

  def legal_types
    LEGAL_TYPES.map {|ref, label| [label, ref.to_s]}
  end

  def subscription_sponsors
    Subscription.all.select(:id, :category, :structure_data, :person_data).map {|s| [s.label, s.id]}
  end

  def deposit_choices
    [
        ['Avant le 16/03/2020', 'before'],
        ['Après le 16/03/2020', 'after'],
        ['Ne sait pas', 'unavailable']
    ]
  end
end
