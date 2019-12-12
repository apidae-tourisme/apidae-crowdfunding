document.addEventListener("DOMContentLoaded", function(event) {
    disableNextSteps();
    bindCategorySelector();
    bindAmountDesc();
});

function disableNextSteps() {
    var tabLinks = document.querySelectorAll("a.tabs__link");
    for (var i = 1; i < tabLinks.length; i++) {
        tabLinks[i].classList.remove('js-tablist__link');
    }
}

function bindCategorySelector() {
    var categorySelect = document.querySelector("#category_selector");
    if (categorySelect) {
        categorySelect.onchange = function() {updateCategoryDesc(categorySelect)};
        if (categorySelect.value) {
            updateCategoryDesc(categorySelect);
        }
    }
}

function bindAmountDesc() {
    var amountField = document.querySelector("#subscription_amount");
    if(amountField) {
        setAmountDesc(amountField);
        amountField.onkeyup = function() {
            setAmountDesc(amountField);
        }
    }
}

function setAmountDesc(field) {
    var amountDesc = document.querySelector("#amount_desc");
    if (field.checkValidity() && (parseInt(field.value) % 100 === 0)) {
        amountDesc.innerHTML = 'soit ' + parseInt(field.value) / 100 + ' parts de 100 €';
    } else {
        amountDesc.innerHTML = '';
    }
}

function updateCategoryDesc(categorySelect) {
    var prevCategory = document.querySelector(".category_desc:not(.is-hidden)");
    if (prevCategory) {
        prevCategory.classList.add('is-hidden');
    }
    var newCategory = document.querySelector(".category_desc." + categorySelect.value);
    newCategory.classList.remove('is-hidden');
    document.querySelector("#category_min").innerHTML = newCategory.querySelector("p:last-child").innerHTML;
}

function nextStep(step) {
    if (step === 'type' && document.querySelector("#category_selector").checkValidity()) {
        var nextTab = document.querySelector("a.tab_montant");
        nextTab.classList.add('js-tablist__link');
        nextTab.click();
    }
}

function checkFormValidity(formWrapper) {
    if (formWrapper.checkValidity()) {
        document.querySelector("#submit_mode").value = "submit";
    } else {
        var invalidFields = formWrapper.querySelectorAll("input:invalid, select:invalid");
        for (var i = 0; i < invalidFields.length; i++) {
            invalidFields[i].parentElement.previousElementSibling.classList.add('invalid_field');
        }
        var tabs = formWrapper.querySelectorAll(".js-tabcontent"), tabsEntries = formWrapper.querySelectorAll(".js-tablist__item");
        for (var i = 0; i < tabs.length; i++) {
            if (tabs[i].querySelector(".invalid_field")) {
                tabsEntries[i].classList.add('invalid_tab');
            }
        }
    }
}