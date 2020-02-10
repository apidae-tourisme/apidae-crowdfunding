var steps = ['type', 'montant', 'infos', 'validation'];

document.addEventListener("DOMContentLoaded", function(event) {
    disableNextSteps();
    bindCategorySelector();
    bindAmountDesc();
    bindLegalTypeSelector();
    initMemberSelector();
    initSignatureFileLabel();
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
        categorySelect.onchange = function() {updateCategoryFields(categorySelect)};
        if (categorySelect.value) {
            updateCategoryFields(categorySelect);
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

function updateCategoryFields(categorySelect) {
    var prevCategory = document.querySelector(".category_desc:not(.is-hidden)");
    if (prevCategory) {
        prevCategory.classList.add('is-hidden');
    }
    var newCategory = document.querySelector(".category_desc." + categorySelect.value);
    newCategory.classList.remove('is-hidden');
    var newAmount = newCategory.querySelector(".min_amount").innerHTML;
    document.querySelector("#subscription_amount").setAttribute('min', newAmount);

    document.querySelector("#category_min").innerHTML = newCategory.querySelector("p:last-child").innerHTML;
    if (categorySelect.value === 'at' || categorySelect.value === 'ct') {
        document.querySelector("#spl_alert").classList.remove('is-hidden');
    } else {
        document.querySelector("#spl_alert").classList.add('is-hidden');
    }

    if (categorySelect.value === 'sr') {
        document.querySelector("#person_type_field").classList.remove('is-hidden');
    } else {
        document.querySelector("#person_type_field").classList.add('is-hidden');
    }

    var structureFields = document.querySelectorAll("#infos .structure_only"),
        personFields = document.querySelectorAll("form .person_pp_only"),
        inputs;
    if (categorySelect.value === 'sr' || categorySelect.value === 'sa') {
        for (var i = 0; i < structureFields.length; i++) {
            structureFields[i].classList.add('is-hidden');
            inputs = structureFields[i].querySelectorAll('input, select');
            for (var k = 0; k < inputs.length; k++) {
                inputs[k].setAttribute('disabled', 'disabled');
            }
        }
        document.querySelector("#subscription_role").removeAttribute('required');
        document.querySelector("label[for='subscription_role'] sup").remove();
        for (var m = 0; m < personFields.length; m++) {
            personFields[m].classList.remove('is-hidden');
            inputs = personFields[m].querySelectorAll('input, select');
            for (var n = 0; n < inputs.length; n++) {
                inputs[n].removeAttribute('disabled');
            }
        }
    } else {
        for (var j = 0; j < structureFields.length; j++) {
            structureFields[j].classList.remove('is-hidden');
            inputs = structureFields[j].querySelectorAll('input, select');
            for (var l = 0; l < inputs.length; l++) {
                inputs[l].removeAttribute('disabled');
            }
        }
        document.querySelector("#subscription_role").setAttribute('required', 'required');
        for (var o = 0; o < personFields.length; o++) {
            personFields[o].classList.add('is-hidden');
            inputs = personFields[o].querySelectorAll('input, select');
            for (var p = 0; p < inputs.length; p++) {
                inputs[p].setAttribute('disabled', 'disabled');
            }
        }
    }
}

function bindLegalTypeSelector() {
    var legalTypeSelect = document.querySelector("#subscription_legal_type");
    if (legalTypeSelect) {
        legalTypeSelect.onchange = function() { toggleLegalTypeDesc(legalTypeSelect); };
        if (legalTypeSelect.value) {
            toggleLegalTypeDesc(legalTypeSelect);
        }
    }
}

function toggleLegalTypeDesc(legalTypeSelect) {
    var typeDesc = document.querySelector("#subscription_legal_type_desc");
    if (legalTypeSelect.value === 'autre') {
        typeDesc.classList.remove('is-hidden');
        typeDesc.removeAttribute('disabled');
    } else {
        typeDesc.classList.add('is-hidden');
        typeDesc.setAttribute('disabled', 'disabled');
    }
}

function nextStep(step) {
    var stepIdx = steps.indexOf(step);
    if (checkStepValidity(step)) {
        var nextStep = steps[stepIdx + 1];
        var nextTab = document.querySelector("a.tab_" + nextStep);
        nextTab.classList.add('js-tablist__link');
        nextTab.click();
        if (nextStep === 'validation') {
            generateValidationMsg();
        }
    }
}

function prevStep(step) {
    var stepIdx = steps.indexOf(step);
    var prevTab = document.querySelector("a.tab_" + steps[stepIdx - 1]);
    prevTab.click();
}

function checkStepValidity(step) {
    var isValid = true;
    var formWrapper = document.querySelector("#subscription_form"),
        formSection = document.querySelector("#subscription_form #" + step);
    var formElts = formSection.querySelectorAll("input, select, textarea");
    formSection.classList.add('submitted');
    for (var i = 0; i < formElts.length; i++) {
        isValid = isValid && formElts[i].checkValidity();
    }
    if (!isValid) {
        var invalidFields = formSection.querySelectorAll("*:invalid");
        for (var j = 0; j < invalidFields.length; j++) {
            var fieldWrapper = invalidFields[j].parentElement.previousElementSibling || invalidFields[j].parentElement.parentElement;
            fieldWrapper.classList.add('invalid_field');
        }
        var tabs = formWrapper.querySelectorAll(".js-tabcontent"),
            tabsEntries = formWrapper.querySelectorAll(".js-tablist__item");
        for (var k = 0; k < tabs.length; k++) {
            if (tabs[k].querySelector(".invalid_field")) {
                tabsEntries[k].classList.add('invalid_tab');
            }
        }
    }
    return isValid;
}

function generateValidationMsg() {
    var categorySelect = document.querySelector("#category_selector");
    var msgWrapper = document.querySelector("#validation_msg");
    var amount = document.querySelector("#subscription_amount").value;
    if (categorySelect.value === 'sr' || categorySelect.value === 'sa') {
        var title = document.querySelector("#subscription_title").value, firstName = document.querySelector("#subscription_first_name").value,
            lastName = document.querySelector("#subscription_last_name").value, address = document.querySelector("#subscription_address").value,
            postalCode = document.querySelector("#subscription_postal_code").value, town = document.querySelector("#subscription_town").value;
        msgWrapper.innerHTML = "Je déclare " + [title, firstName, lastName].join(" ") + " domicilié(e) à " +
            [address, postalCode, town].join(" ") + "<br/>m'engage à investir " + formatAmount(amount) + " soit " + (parseInt(amount) / 100) + " parts de 100 €."
    } else {
        var structureName = document.querySelector("#subscription_structure_name").value;
        msgWrapper.innerHTML = structureName + "<br/>s'engage à investir " + formatAmount(amount) + " soit " + (parseInt(amount) / 100) + " parts de 100 €."
    }
}

function initMemberSelector() {
    accessibleAutocomplete({
        element: document.querySelector(".lookup_container"),
        id: 'member_autocomplete',
        source: function suggest(query, populateResults) {
            searchMembers(query, populateResults);
        },
        templates: {
            inputValue: function(res) {return res ? res.text : '';},
            suggestion: function(res) {return res ? res.text : '';}
        },
        onConfirm: function(res) {
            if (res && res.id) {
                document.querySelector('#subscription_apidae_member_id').setAttribute('value', res.id);
                document.querySelector('#subscription_structure_name').setAttribute('value', res.text);
            }
        },
        placeholder: 'Rechercher un membre Apidae...',
        displayMenu: 'overlay',
        minLength: 2,
        tNoResults: function() {return 'Aucun résultat.';},
        tStatusQueryTooShort: function(l) {return 'Veuillez saisir au moins ' + l + ' caractères.';},
        tStatusNoResults: function() {return 'Aucun résultat.';},
        tStatusSelectedOption: function(selected, length, idx) {return 'Option ' + selected.text + ' (' + (idx + 1) + ' sur ' + length + ') sélectionnée.';},
        tStatusResults: function(length, selectedMsg) {return length + ' résultat(s). ' + selectedMsg;}
    })
}

function searchMembers(query, callback) {
    var ajax = new XMLHttpRequest();
    ajax.open("GET", "/souscriptions/members.json?pattern=" + query, true);
    ajax.onload = function() {
        callback(JSON.parse(ajax.responseText).members);
    };
    ajax.send();
}

var signaturePad;
function toggleSignaturePad() {
    var onlineSigning = document.querySelector("#online_signing");
    var canvasWrapper = document.querySelector("#signing_canvas");
    if (onlineSigning.checked) {
        canvasWrapper.classList.remove('is-hidden');
        if (!signaturePad) {
            signaturePad = new SignaturePad(canvasWrapper.querySelector("canvas"));
            window.onresize = resizeCanvas;
            resizeCanvas();
        }
    } else {
        signaturePad.clear();
        canvasWrapper.classList.add('is-hidden');
    }
}

function resizeCanvas() {
    var canvas = document.querySelector("#signing_canvas canvas");
    var ratio =  Math.max(window.devicePixelRatio || 1, 1);
    canvas.width = canvas.offsetWidth * ratio;
    canvas.height = canvas.offsetHeight * ratio;
    canvas.getContext("2d").scale(ratio, ratio);
    signaturePad.clear();
}

function clearPad() {
    if (signaturePad) {
        signaturePad.clear();
    }
}

function initSignatureFileLabel() {
    var inputFile = document.querySelector("#signature_file");
    inputFile.addEventListener('change', function() {
        document.querySelector("#download_signature").innerHTML = inputFile.files[0].name;
    });
}

function copySignature() {
    var inputFile = document.querySelector("#signature_file");
    if (signaturePad && !signaturePad.isEmpty() && !inputFile.value) {
        document.querySelector("#signature_data").value = signaturePad.toDataURL();
        document.querySelector("#subscription_signed_at").value = new Date().toISOString();
    }
}