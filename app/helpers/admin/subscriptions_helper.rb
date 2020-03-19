module Admin::SubscriptionsHelper
  def export_columns
    [:created_at, :status, :signed_at, :id, :label, :structure_name, :title, :first_name, :last_name, :category, :apidae_member_id,
     :amount, :siret, :legal_entity_type, :role, :address, :postal_code, :town, :country, :telephone, :email,
     :website, :fund_deposit, :payment_method, :com_enabled, :sponsor_label]
  end

  def export_values(subscription)
    vals = []
    export_columns.each do |col|
      if col == :category
        vals << CATEGORIES[subscription.send(col).to_sym][:name]
      elsif [:country, :fund_deposit, :status, :payment_method].include?(col)
        vals << (subscription.send(col).blank? ? '' : I18n.t("export.subscription.value.#{subscription.send(col)}"))
      else
        vals << subscription.send(col)
      end
    end
    vals
  end
end
