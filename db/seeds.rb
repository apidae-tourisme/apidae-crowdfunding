# Template "Apidae crowdfunding"
site_template = Sibu::SiteTemplate.find_or_create_by(name: "Apidae - Souscription")
site_template.update(
    path: "templates/subscription",
    ref: "subscription",
    primary_font: "Niramit",
    secondary_font: "Niramit",
    primary_color: "#0089ce",
    secondary_color: "#f46754",
    sections: [
      {id: 'header', elements: [{id: 'header_title', text: Sibu::DEFAULT_TEXT}]}
    ],
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
        },
        hexa_grid: {
            elements: [
                {id: 'title', text: Sibu::DEFAULT_TEXT},
                {id: 'links', elements: [
                    {id: 'link1', text: 'Lien 1', value: '#'},
                    {id: 'link2', text: 'Lien 2', value: '#'}
                ]}
            ]
        },
        steps: {
            elements: [
                {id: 'title', text: Sibu::DEFAULT_TEXT},
                {id: 'subtitle', text: Sibu::DEFAULT_TEXT},
                {id: 'steps', elements: [
                    {id: 'step1', elements: [
                        {id: 'label', text: 'Etape 1'},
                        {id: 'link', text: 'Lien 1', value: '#'}
                    ]},
                    {id: 'step2', elements: [
                        {id: 'label', text: 'Etape 2'},
                        {id: 'link', text: 'Lien 2', value: '#'}
                    ]}
                ]}
            ]
        },
        step_tab_with_tabs: {
            elements: [
                {id: 'intro', text: Sibu::DEFAULT_PARAGRAPH},
                {id: 'tabs', elements: [
                    {id: 'tab1', text: 'Onglet 1'},
                    {id: 'tab2', text: 'Onglet 2'}
                ]},
                {id: 'contents', elements: [
                    {id: 'content1', elements: [
                        {id: 'title', text: Sibu::DEFAULT_TEXT},
                        {id: 'text', text: Sibu::DEFAULT_PARAGRAPH}
                    ]},
                    {id: 'content2', elements: [
                        {id: 'title', text: Sibu::DEFAULT_TEXT},
                        {id: 'text', text: Sibu::DEFAULT_PARAGRAPH}
                    ]}
                ]}
            ]
        },
        hexa_steps: {
            elements: [
                {id: 'title', text: Sibu::DEFAULT_TEXT},
                {id: 'steps', elements: [
                    {id: 'step1', text: Sibu::DEFAULT_TEXT},
                    {id: 'step2', text: Sibu::DEFAULT_TEXT}
                ]},
                {id: 'link', text: Sibu::DEFAULT_TEXT, value: '#'}
            ]
        }
    }
)