class ApidaeMember < ApplicationRecord
  def self.lookup_by_name(pattern)
    where("trim(unaccent(replace(name, '-', ' '))) ILIKE trim(unaccent(replace(?, '-', ' ')))", "%#{pattern}%")
  end
end
