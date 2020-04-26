function initializeDatatable(tableSelector, defaultSorting) {
    var table = document.querySelector(tableSelector);
    if (table) {
        var columnsCount = table.querySelectorAll("thead th").length;
        datatable = new DataTable(table, {
            columns: [
                {select: defaultSorting, sort: "asc"},
                {select: columnsCount - 1, sortable: false}
            ],
            labels: {
                placeholder: "Rechercher...",
                perPage: "{select} résultats par page",
                noRows: "Aucun résultat",
                info: "Résultats {start} - {end} sur {rows}",
            }
        });
    }
}