CATEGORIES = {
    mo: {name: "Moteurs de l’économie territoriale", desc: "Personnes morales et collectivités territoriales, associées de la Scic dont l'intérêt principal est de contribuer à la structuration et au développement économique des territoires et qui, à ce titre souhaitent s’investir fortement dans le projet. Ex : Régions.", shares: 1000, amount: 100000},
    fi: {name: 'Financeurs', desc: "Personnes morales, associées de la Scic dont l'intérêt principal est de contribuer à la structuration et au développement économique des territoires et qui, à ce titre souhaitent s’investir fortement dans le projet sans participation opérationnelle. Ex : investisseurs privés."},
    ct: {name: 'Coordinateurs territoriaux', desc: "Personnes morales et collectivités en charge du développement de l’économie locale et/ou de la structuration de leur territoire qui mettent à dispo du réseau des ressources humaines pour l'accompagnement des utilisateurs de la plateforme dans le cadre d'une convention spécifique passée avec la Scic. Ex : Comités Départementaux de tourisme, Conseils Départementaux.", shares: 50, amount: 5000},
    at: {name: 'Acteurs territoriaux', desc: "Personnes morales en charge du développement de l’économie locale, d’une marque ou d’une destination touristique, et qui utilisent les services de la plateforme via un abonnement. Ex : Offices de Tourisme, Communautés de Communes.", shares: 10, amount: 1000},
    sr: {name: 'Soutiens', desc: "Personnes physiques ou morales souhaitant apporter un soutien au réseau (financier, expertise, apport de données …) et s’impliquer dans la gouvernance. Ex : greeters, ambassadeurs.", shares:1, amount: 100},
    fs: {name: 'Fournisseurs de services', desc: "Personnes morales et personnes physiques, opérateurs économiques variés, qui proposent des services à destination des autres communautés, et qui utilisent les services de la plateforme via unabonnement. Ex : agences web, éditeurs de logiciels, start-ups.", shares: 10, amount: 1000},
    sa: {name: 'Salariés', desc: "Personnes physiques ayant un contrat de travail avec la Scic.", shares: 1, amount: 100},
    sp: {name: 'Socio-professionnels', desc: "Personnes morales et personnes physiques, professionnels de l’économie touristique, qui commercialisent des biens et des services, à destination des touristes ou des habitants, et qui utilisent les services de la plateforme via un abonnement. Ex : hébergeurs, prestataires d’activités.", shares: 5, amount: 500}
}

LEGAL_TYPES = {
    association: "Association",
    collectivite_territoriale: "Collectivité territoriale (commune, Conseil Départemental, Région, etc.)",
    regie_autonome: "Régie autonome",
    epic: "Régie personnalisée gestionnaire d'un Etablissement Public Industriel et Commercial (EPIC)",
    spa: "Régie personnalisée gestionnaire d'un Service Public Administratif (SPA)",
    spic: "Régie personnalisée gestionnaire d'un Service Public Industriel et Commercial (SPIC)",
    regie_simple: "Régie simple (régie directe)",
    sem: "Société d'Economie Mixte (SEM)",
    spl: "Société Publique Locale (SPL)",
    autre: "Autre"
}

REGIONS = {
    "ile-de-france": ['75', '91', '92', '77', '93', '95', '94'],
    "centre-val-de-loire": ['18', '28', '36', '37', '41', '45'],
    "bourgogne-france-comte": ['21', '58', '71', '89', '25', '39', '70', '90'],
    "normandie": ['27', '76', '14', '50', '61'],
    "hauts-de-france": ['59', '62', '02', '60', '80'],
    "grand-est": ['67', '68', '08', '10', '51', '52'],
    "pays-de-la-loire": ['44', '49', '53', '72', '85'],
    "bretagne": ['22', '29', '35', '56'],
    "nouvelle-aquitaine": ['16', '17', '19', '23', '24', '33', '40', '47', '64', '79', '86', '87'],
    "occitanie": ['09', '11', '12', '30', '31', '32', '34', '46', '48', '65', '66', '81', '82'],
    "auvergne-rhone-alpes": ['01', '03', '07', '15', '26', '38', '42', '43', '63', '69', '73', '74'],
    "provence-alpes-cote-d-azur": ['04', '05', '06', '13', '83', '84'],
    "corse": ['2A', '2B'],
    "nouvelle-caledonie": ['988'],
    "suisse": ['CH']
}