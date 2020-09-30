const colorsByCategory = {
    mo: '#F97E7E',
    ct: '#74C5EA',
    at: '#FFC302',
    sr: '#FB71A7',
    fs: '#9D9D9C',
    sa: '#BDD07B',
    sp: '#00B1C6'
};

const labelsByCategory = {
    mo: "Moteurs de l’économie territoriale",
    ct: "Coordinateurs territoriaux",
    at: "Acteurs territoriaux",
    sr: "Soutiens du réseau",
    fs: "Fournisseurs de services",
    sa: "Salariés et Producteurs des services de la Scic",
    sp: "Socio-professionnels"
};

var datatable;
var rankingsChart, rankingsData, pieChart, pieData;
var mapFeatures, textFeatures, activeRegion;
var formatAmount = d3.formatLocale({decimal: ',', thousands: ' ', grouping: [3], currency: ['', ' €']}).format('$,');

document.addEventListener("DOMContentLoaded", function (event) {
    var mapWrapper = document.querySelector("#home_map");
    if (mapWrapper) {
        initMap(mapWrapper);
    }
    var chartsWrapper = document.querySelector("#home_charts");
    if (chartsWrapper) {
        initRankingsChart();
        initPieChart();
    }
    initNumbersFormatter();
});

function initNumbersFormatter() {
    var nbrs = document.querySelectorAll("span.nbr");
    for (var i = 0; i < nbrs.length; i++) {
        nbrs[i].innerHTML = formatAmount(nbrs[i].innerHTML);
    }
}

function initDataTable() {
    var table = document.querySelector("#subscriptions_table");
    if (table) {
        datatable = new DataTable(table, {
            fixedHeight: true,
            columns: [
                {
                    select: 0, type: 'number', sort: 'asc',
                    render: function(data, cell, row) {
                        return new Date(parseInt(data)).toLocaleString();
                    }
                },
                {select: 2, type: 'number'}
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

function initMap(mapWrapper) {
    var wrapperRect = mapWrapper.getBoundingClientRect();
    var width = wrapperRect.width, height = wrapperRect.height;
    var scale = width > 480 ? 3000 : 1000;
    var path = d3.geoPath();
    var projection = d3.geoConicConformal() // Lambert-93
        .center([2.454071, 46.279229]) // Center on France
        .scale(scale)
        .translate([width / 2, (height - 60) / 2]);
    path.projection(projection);

    var svg = d3.select('#home_map').append("svg")
        .attr("width", width)
        .attr("height", height);
    var regionsWrapper = svg.append("g");
    svg.append("defs")
        .append('pattern')
        .attr('id', 'flag')
        .attr('patternUnits', 'userSpaceOnUse')
        .attr('width', 100)
        .attr('height', 100)
        .append("image")
        .attr("xlink:href", "eu_flag.png")
        .attr('width', width > 480 ? 25 : 20)
        .attr('height', 100)
        .attr('x', width > 480 ? 35 : 70)
        .attr('y', width > 480 ? -10 : 10);
    var promises = [
        d3.json('/data/regions.json'),
        d3.json('/souscriptions/regions.json')
    ];
    activeRegion = d3.select(null);

    Promise.all(promises).then(function (values) {
        var regionsData = values[0];
        var subscriptionsData = values[1];

        mapFeatures = regionsWrapper
            .selectAll("path")
            .data(regionsData.features)
            .enter().append("g").attr("class", function(d) {return "map_region " + d.properties.reference;});

        mapFeatures.append("path")
            .attr("id", function (d) {
                return d.properties.reference;
            })
            .attr("class", function (d) {
                return "region_path " + subscriptionLevel(d.properties.reference, subscriptionsData);
            })
            .attr("d", path)
            .on("click", focusOnRegion);
        textFeatures = regionsWrapper
            .selectAll("text")
            .data(regionsData.features)
            .enter().append("g").attr("class", function(d) {return "map_region region_text " + d.properties.reference;});
        textFeatures.append("text").attr("class", "region_label")
            .html(function (d) {
                var count = subscriptionCount(d.properties.reference, subscriptionsData);
                return count  > 0 ? ('<tspan class="map_text" x="0" y="0">' + formatAmount(count * 100) + '</tspan><tspan class="map_text" x="0" dy="1em">déclarés</tspan>') : '';
            }).on("click", focusOnRegion);

        d3.selectAll("text.region_label").attr("transform", function (d, i) {
            var bbox = document.querySelector("#" + d.properties.reference).getBBox();
            return "translate(" + (bbox.x + bbox.width / 2) + " " + (bbox.y + bbox.height / 2) + ")";
        });
    });

    function focusOnRegion(d) {
        if (activeRegion === d.properties.reference) return resetMapZoom();
        var previousElts = document.querySelectorAll(".map_region.active");
        for (var i = 0; i < previousElts.length; i++) {
            previousElts[i].classList.remove('active');
        }
        var activeElts = document.querySelectorAll(".map_region." + d.properties.reference);
        for (var j = 0; j < activeElts.length; j++) {
            activeElts[j].classList.add('active');
        }
        activeRegion = d.properties.reference;

        var bounds = path.bounds(d),
            dx = bounds[1][0] - bounds[0][0],
            dy = bounds[1][1] - bounds[0][1],
            x = (bounds[0][0] + bounds[1][0]) / 2,
            y = (bounds[0][1] + bounds[1][1]) / 2,
            scale = .9 / Math.max(dx / width, dy / height),
            translate = [width / 2 - scale * x, height / 2 - scale * y];

        mapWrapper.classList.add('zoomed', 'zooming');
        mapFeatures.transition()
            .duration(750)
            .attr("transform", "translate(" + translate + ") scale(" + scale + ")");
        setTimeout(function() {
            var textTransform = document.querySelector(".map_region.region_text." + d.properties.reference + " > text")
                .getAttribute("transform");
            d3.select(".map_region.region_text." + d.properties.reference)
                .attr("transform", "translate(" + translate + ") scale(" + scale + ")")
                .append("text")
                .attr("transform", textTransform)
                .attr("class", "region_label")
                .html('<tspan class="zoomed_text" x="0" y="0" dy="-1.4em">' + d.properties.nom + '</tspan>');
            mapWrapper.classList.remove('zooming');
            clearActiveCategory();
            initPieChart(d.properties.reference);
            initRankingsChart(d.properties.reference);
        }, 750);
    }

    function subscriptionCount(ref, subscriptions) {
        return (subscriptions[ref] || 0) / 100;
    }

    function subscriptionLevel(ref, subscriptions) {
        return countLevel(subscriptionCount(ref, subscriptions));
    }

    function countLevel(subscriptionsCount) {
        var levels = [0, 5, 10, 25, 50, 100, 150, 200, 300, 1000000];
        for (var i = 0; i < levels.length - 1; i++) {
            if (subscriptionsCount >= levels[i] && subscriptionsCount < levels[i + 1]) {
                return "level_" + i;
            }
        }
    }
}

function resetMapZoom(filter) {
    var mapWrapper = document.querySelector("#home_map");
    mapWrapper.classList.add('zooming');
    mapFeatures.transition()
        .duration(750)
        .attr("transform", "");

    setTimeout(function() {
        var activeText = d3.select(".map_region.region_text.active");
        activeText.attr("transform", "");
        activeText.select("text:last-child").remove();
        var previousElts = document.querySelectorAll(".map_region.active");
        for (var i = 0; i < previousElts.length; i++) {
            previousElts[i].classList.remove('active');
        }
        activeRegion = '';
        document.querySelector("#home_map").classList.remove('zoomed', 'zooming');
        initPieChart(filter);
        initRankingsChart(filter);
    }, 750);
}

function toggleRankFilter(filter, btn) {
    if (!btn.classList.contains('active')) {
        if (document.querySelector("#home_map").classList.contains('zoomed')) {
            resetMapZoom(filter);
        } else {
            initRankingsChart(filter);
            initPieChart(filter);
        }
        clearActiveCategory();
        btn.classList.add('active');
    } else {
        initRankingsChart();
        initPieChart();
        btn.classList.remove('active');
    }
}

function initRankingsChart(filter) {
    var ajax = new XMLHttpRequest();
    ajax.open("GET", "/souscriptions/rankings.json" + (filter ? ("?filter=" + filter) : ""), true);
    ajax.onload = function () {
        var containerElt = document.querySelector('#rank_chart');
        var resp = ajax.responseText;
        rankingsData = JSON.parse(resp);
        if (rankingsData.length) {
            containerElt.classList.remove('empty_chart');
            if (rankingsChart) {
                loadRankingsData(rankingsChart, rankingsData);
            } else {
                rankingsChart = c3.generate({
                    bindto: '#rank_chart',
                    size: {
                        height: 200,
                        width: 300
                    },
                    data: {
                        json: [],
                        type: 'bar',
                        labels: {
                            format: function (v, id, i, j) {
                                return null;
                            }
                        },
                        keys: {
                            x: 'id',
                            value: ['value']
                        },
                        color: function (color, d) {
                            return (typeof d === 'object') ? colorsByCategory[rankingsData[d.index].category] : color;
                        }
                    },
                    axis: {
                        rotated: true,
                        x: {
                            type: 'category',
                            tick: {
                                multiline: false,
                                format: function (x) {
                                    return rankingsData[x] ? (rankingsData[x].label + ' - ' + formatAmount(rankingsData[x].amount)) : '';
                                }
                            }
                        },
                        y: {
                            inner: true
                        }
                    },
                    legend: {show: false},
                    interaction: {enabled: false},
                    bar: {
                        width: {
                            ratio: 0.9
                        },
                        space: 0.1
                    },
                    onresize: alignLeftAxis,
                    onrendered: alignLeftAxis
                });
                loadRankingsData(rankingsChart, rankingsData);
            }
        } else {
            containerElt.classList.add('empty_chart');
            containerElt.innerHTML = '<p class="txtcenter txt--white">Aucune donnée à l\'heure actuelle.</p>';
            rankingsChart = null;
        }
    };
    ajax.send();
}

function loadRankingsData(chart, data) {
    chart.load({
        json: data,
        keys: {
            x: 'id',
            value: ['value']
        },
        // Note : this is to fix the rotated x axis on the left
        done: alignLeftAxis
    });
}

function clearActiveCategory() {
    var catBtn = document.querySelector('#pie_legend button.active');
    if (catBtn) {
        catBtn.classList.remove('active');
    }
}

function alignLeftAxis() {
    var grp = document.querySelector("#rank_chart svg > g");
    // if (grp) {
    //     if (window.innerWidth > 575) {
            grp.setAttribute("transform", "translate(0,0)");
        // } else {
        //     grp.setAttribute("transform", "translate(20,5.5)");
        // }
    // }
}

function initPieChart(filter) {
    var ajax = new XMLHttpRequest();
    ajax.open("GET", "/souscriptions/proportions.json" + (filter ? ("?filter=" + filter) : ""), true);
    ajax.onload = function () {
        var resp = ajax.responseText;
        pieData = JSON.parse(resp);
        if (Object.keys(pieData).length && Object.keys(pieData.subscriptions).length) {
            if (pieChart) {
                loadPieData(pieChart, pieData.subscriptions);
                var pieLegend = d3.select('#pie_legend').selectAll('div.legend_item').data(Object.keys(pieData.subscriptions));
                pieLegend.select("button > span:first-child").text(function(d) {
                    return formatAmount(pieData.amounts[d]);
                });
            } else {
                pieChart = c3.generate({
                    bindto: '#pie_chart',
                    size: {
                        height: 280
                    },
                    data: {
                        json: pieData.subscriptions,
                        type: 'pie',
                        color: function(color, d) {
                            return (typeof d === 'string') ? colorsByCategory[d] : color;
                        }
                    },
                    legend: {show: false},
                    interaction: {enabled: false},
                    pie: {
                        label: {
                            format: function (value, ratio, id) {
                                return value + ' membre' + (value > 1 ? 's' : '');
                            }
                        }
                    }
                });
                d3.select('#pie_legend').selectAll('div.legend_item')
                    .data(Object.keys(pieData.subscriptions)).enter().append('div')
                    .attr('class', 'legend_item flex-container--column')
                    .html(function (id) {
                        return '<button type="button" class="flex-container--column ' + id + '" style="border-left-color: ' + colorsByCategory[id] + ';" onclick="toggleRankFilter(\'' + id + '\', this)">' +
                            '<span class="fw500" style="color: ' + colorsByCategory[id] + ';">' + formatAmount(pieData.amounts[id]) + '</span>' +
                            '<span class="txt--white">' + labelsByCategory[id] + '</span></button>';
                    })
                    .on('mouseover', function (id) {
                        if (pieChart) pieChart.focus(id);
                    })
                    .on('mouseout', function (id) {
                        if (pieChart) pieChart.revert();
                    });
            }
        } else {
            pieChart = null;
            document.querySelector("#pie_chart").innerHTML = '<p class="txtcenter txt--white">Aucune donnée à l\'heure actuelle.</p>';
        }
    };
    ajax.send();
}

function loadPieData(chart, data) {
    chart.load({
        json: data
    });
}

function loadSubscriptions() {
    var formatNoCurrency = d3.formatLocale({decimal: ',', thousands: ' ', grouping: [3]}).format(',');
    var container = document.querySelector("#subscriptions_wrapper");
    container.innerHTML =
        '<table id="subscriptions_table" class="data_table table--zebra">' +
        '  <thead class="bg--primary">' +
        '    <tr class="txtcenter">' +
        '      <th>Date</th>' +
        '      <th>Nom</th>' +
        '      <th>Montant (€)</th>' +
        '      <th>Catégorie</th>' +
        '    </tr>' +
        '  </thead>' +
        '  <tbody>' +
        '  </tbody>' +
        '</table>';
    var rowsContainer = document.querySelector('#subscriptions_table tbody');
    var ajax = new XMLHttpRequest();
    ajax.open("GET", "/souscriptions.json", true);
    ajax.onload = function () {
        var resp = ajax.responseText;
        var subscriptionsData = JSON.parse(resp);
        for (var i = 0; i < subscriptionsData.length; i++) {
            rowsContainer.innerHTML += '<tr class="txtcenter">' +
                '<td>' + subscriptionsData[i].date + '</td>' +
                '<td>' + subscriptionsData[i].label + '</td>' +
                '<td>' + formatNoCurrency(subscriptionsData[i].amount) + '</td>' +
                '<td>' + labelsByCategory[subscriptionsData[i].category] + '</td>' +
            '</tr>'
        }
        initDataTable();
    };
    ajax.send();
}