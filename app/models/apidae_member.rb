require 'open-uri'

class ApidaeMember < ApplicationRecord
  PHONE = 201
  EMAIL = 204
  WEBSITE = 205

  def self.lookup_by_name(pattern)
    where("trim(unaccent(replace(name, '-', ' '))) ILIKE trim(unaccent(replace(?, '-', ' ')))", "%#{pattern}%")
  end

  def retrieve_info
    info = {}
    unless legal_entity_id.blank?
      response = ''
      query = api_query
      logger.debug "Apidae API query : #{query}"
      open(query) { |f|
        f.each_line {|line| response += line if line}
      }
      unless response.blank?
        info_fields = JSON.parse(response, symbolize_names: true)
        info.merge! parse_contact_info(info_fields[:informations][:moyensCommunication])
        info.merge! parse_address_info(info_fields[:localisation])
      end

    end
    info
  end

  def api_query
    "#{Rails.application.config.apidae_api_url}/objet-touristique/get-by-id/#{legal_entity_id}?apiKey=#{Rails.application.config.apidae_project_key}&projetId=#{Rails.application.config.apidae_project_id}&responseFields=@all"
  end

  def parse_contact_info(com_hash)
    contact_info = {}
    contact_entries = com_hash || []
    contact_entries.each do |c|
      case c[:type][:id]
      when PHONE
        contact_info[:telephone] ||= c[:coordonnees][:fr]
      when EMAIL
        contact_info[:email] ||= c[:coordonnees][:fr]
      when WEBSITE
        contact_info[:website] ||= c[:coordonnees][:fr]
      else
      end
    end
    contact_info
  end

  def parse_address_info(location_hash)
    loc_info = {}
    unless location_hash.blank?
      address_hash = location_hash[:adresse]
      computed_address = []
      unless address_hash.blank?
        computed_address << address_hash[:adresse1] unless address_hash[:adresse1].blank?
        computed_address << address_hash[:adresse2] unless address_hash[:adresse2].blank?
        computed_address << address_hash[:adresse3] unless address_hash[:adresse3].blank?
      end
      loc_info.merge!({
                          address: computed_address.first,
                          town: address_hash[:commune][:nom],
                          postal_code: address_hash[:commune][:codePostal]
                      })
    end
    loc_info
  end
end
