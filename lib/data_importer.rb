require 'open-uri'
require 'json'

class DataImporter
  def self.import_members
    json_response = ''
    open(MEMBERS_API_URL) { |f|
      f.each_line { |line| json_response += line if line }
    }
    members_data = JSON.parse(json_response, symbolize_names: true)
    members_data.each do |m|
      mbr = ApidaeMember.find_or_create_by(apidae_id: m[:id])
      mbr.name  = m[:nom]
      mbr.legal_entity_id = m[:entitesJuridiques].find {|e| e[:entitePrincipale] == true}[:id] unless m[:entitesJuridiques].blank?
      mbr.save
    end
  end
end