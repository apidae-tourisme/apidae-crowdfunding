SECTIONS_TABS = ['texts', 'links', 'grids', 'custom']

Rails.application.config.sibu = {
    title: 'Souscription Apidae',
    stylesheet: 'admin',
    javascript: 'admin',
    top_panel: 'shared/admin_header',
    content_panel: 'shared/admin_content',
    bottom_panel: 'shared/admin_footer',
    auth_filter: :authenticate_user!,
    admin_filter: Proc.new {|usr| true},
    current_user: 'current_user',
    host: 'localhost',
    not_found: 'shared/templates/not_found',
    images: {large: 1600, medium: 800, small: 320},
    section_form: 'shared/sibu/section_form',
    sections_ordering: Proc.new {|sections| sections.sort_by {|s| SECTIONS_TABS.index(s['category'])}}
}
