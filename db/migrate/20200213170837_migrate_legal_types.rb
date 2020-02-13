class MigrateLegalTypes < ActiveRecord::Migration[5.2]
  def change
    bindings = {
        "sarl" => 'sarl',
        "sas" => 'sas',
        "epic" => 'epic',
        "eurl" => 'eurl',
        "scop-sarl" => 'cooperative'
    }
    Subscription.where("structure_data->>'legal_type' = ?", 'autre').each do |s|
      lt = s.legal_type_desc.parameterize
      if bindings[lt]
        s.update(legal_type: bindings[lt])
      end
    end
  end
end
