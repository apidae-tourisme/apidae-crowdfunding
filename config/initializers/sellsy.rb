require 'sellsy'

begin
  Sellsy::Api.configure do |config|
    config.consumer_token = Rails.application.config.sellsy_consumer_token
    config.consumer_secret = Rails.application.config.sellsy_consumer_secret
    config.user_token = Rails.application.config.sellsy_user_token
    config.user_secret = Rails.application.config.sellsy_user_secret
  end

  resp = Sellsy::CustomField.all
  SELLSY_CUSTOM_FIELDS = Hash[
      resp.values.map do |ref|
        [
            ref['code'],
            {
                id: ref['id'],
                label: ref['name'],
                values: ref['prefsList'].blank? ? nil : ref['prefsList'].values.map { |v| {id: v['id'], cfid: v['cfid'], value: v['value']} }
            }
        ]
      end
  ]
rescue Exception => ex
  Rails.logger.error("Could not load Sellsy custom fields : " + ex.message)
  SELLSY_CUSTOM_FIELDS = {}
end

SELLSY_STATUT_JURIDIQUE = "statutjuridique"
SELLSY_LIBERATION_MONTANT = "liberationmontant"
SELLSY_TYPE_COLLEGE = "typecollege"
SELLSY_SECTEUR_ACTIVITE = "secteur"
SELLSY_REFERENT_SOCIETAIRE = "referentsocietaireliste"
SELLSY_NB_PARTS = "nbrepartssouscrites"
SELLSY_NUM_SOUSCRIPTION = "numsouscription"
SELLSY_MOYEN_PAIEMENT = "moyenpaiement"
SELLSY_CATEGORIE_SOCIETAIRE = "categoriesocietaire"