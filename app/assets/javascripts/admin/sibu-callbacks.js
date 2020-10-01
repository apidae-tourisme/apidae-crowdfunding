function indexImagesSibuCallback() {
    stylePage();
    initializeDatatable('#images table', 0);
}

function indexDocumentsSibuCallback() {
    stylePage();
    initializeDatatable('#documents table', 0);
}

function newImagesSibuCallback() {
    stylePage();
}

function indexPagesSibuCallback() {
    stylePage();
    initializeDatatable('#pages table', 3);
}

function newPagesSibuCallback() {
    stylePage();
}

function editPagesSibuCallback() {
    stylePage();
}

function indexSitesSibuCallback() {
    stylePage();
}

function editSitesSibuCallback() {
    stylePage();
}

function newSitesSibuCallback() {
    stylePage();
}

function editContentSibuCallback() {
    stylePage();
    document.addEventListener("DOMContentLoaded", function (event) {
        var tabsCount = document.querySelectorAll(".js-tablist > li").length,
            tabsContents = document.querySelectorAll(".js-tabcontent");
        if (tabsCount > tabsContents.length) {
            for (var i = 0; i < tabsContents.length; i++) {
                tabsContents[i].removeAttribute('aria-hidden');
            }
        }
    });
}

function newSectionSibuCallback() {
    // var tabs = document.querySelectorAll(".sibu_sections_tabs [data-tabs]");
    // for (var i = 0; i < tabs.length; i++) {
        try {
            new Tabby(".sibu_sections_tabs .step_tab_with_tabs [data-tabs]");
        } catch (e) {
            console.error('skipping invalid tab init');
        }
    // }
}

function editElementSibuCallback() {
    stylePage();
    // initializeDatatable('#edit_panel .sibu_images', 0);
}

function stylePage() {
    var title = document.querySelector(".sibu_view .actions + h2");
    if (title && !title.classList.contains('h1-like')) {
        title.classList.add('h1-like', 'txtleft', 'item-fluid', 'u-uppercase');
    }
    var actions = document.querySelectorAll(".sibu_view > .actions a, .edit_mode_actions button, #element_actions button");
    for (var i = 0; i < actions.length; i++) {
        if(!actions[i].classList.contains('btn')) {
            actions[i].classList.add('btn');
        }
    }

    var table = document.querySelector(".sibu_view > table");
    if (table) {
        table.classList.add('data_table', 'table--zebra');
        table.querySelector("thead").classList.add('bg--inverse');
        var rows = table.querySelectorAll("tr");
        for (var j = 0; j < rows.length; j++) {
            rows[j].classList.add('txtcenter');
        }
    }
}