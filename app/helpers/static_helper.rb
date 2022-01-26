module StaticHelper
  def apidae_icons
    ['apidae-icon-chevronright', 'apidae-icon-chevronleft', 'apidae-icon-clock', 'apidae-icon-map', 'apidae-icon-news',
     'apidae-icon-action', 'apidae-icon-arrowdown', 'apidae-icon-arrowleft', 'apidae-icon-arrowright', 'apidae-icon-arrowup',
     'apidae-icon-bee', 'apidae-icon-cancel', 'apidae-icon-chevronleftfilled', 'apidae-icon-chevronrightfilled',
     'apidae-icon-close', 'apidae-icon-creativework', 'apidae-icon-event', 'apidae-icon-idea', 'apidae-icon-list',
     'apidae-icon-organization', 'apidae-icon-pen', 'apidae-icon-person', 'apidae-icon-plus', 'apidae-icon-product',
     'apidae-icon-project', 'apidae-icon-role', 'apidae-icon-search', 'apidae-icon-service', 'apidae-icon-share',
     'apidae-icon-star', 'apidae-icon-validate', 'apidae-icon-hexa']
  end

  def amount_ratio
    [100, (Subscription.sum(:amount).to_i / 670000.0).round(2) * 100].min.to_i
  end
end
