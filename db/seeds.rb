# Template "Apidae crowdfunding"
site_template = Sibu::SiteTemplate.find_or_create_by(name: "Apidae - Souscription")
site_template.update(
    path: "templates/subscription",
    ref: "subscription",
    primary_font: "Montserrat",
    secondary_font: "Montserrat",
    primary_color: "#00B1C6",
    secondary_color: "#F97E7E",
    sections: [],
    pages: [
        {
            name: "Page générique", path: "", sections: [
            {id: "page_title", category: "texts", template: "title", elements: [
                {id: "title", text: Sibu::DEFAULT_TEXT}
            ]}
        ]
        }
    ],
    templates: {
        categories_tabs: {
            elements: [
                {id: 'tabs', elements: [
                    {id: 'tab_0', text: 'Onglet 1'},
                    {id: 'tab_1', text: 'Onglet 2'}
                ]},
                {id: "contents", elements: [
                    {id: "content_0", elements: [
                        {id: "content_title", text: 'Titre onglet 1'},
                        {id: "content_text", text: Sibu::DEFAULT_PARAGRAPH}
                    ]},
                    {id: "content_1", elements: [
                        {id: "content_title", text: 'Titre onglet 2'},
                        {id: "content_text", text: Sibu::DEFAULT_PARAGRAPH}
                    ]}
                ]}
            ]
        },
        posts_list: {
            elements: [
                {id: 'items'}
            ]
        }
    }
)