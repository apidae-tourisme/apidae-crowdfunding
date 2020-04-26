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
    templates: {}
)