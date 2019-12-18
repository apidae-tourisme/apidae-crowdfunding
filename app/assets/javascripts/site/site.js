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
    sr: "Soutiens",
    fs: "Fournisseurs de services",
    sa: "Salariés de la Scic",
    sp: "Socio-professionnels"
};

var rankingsChart, rankingsData, pieChart, pieData;
var mapFeatures, activeRegion;
var formatAmount = d3.formatLocale({decimal: ',', thousands: ' ', grouping: [3], currency: ['', '€']}).format('$,');

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
    var subscriptionsWrapper = document.querySelector("#all_subscriptions");
    if (subscriptionsWrapper) {
        loadSubscriptions(subscriptionsWrapper);
    }
});

function initMap(mapWrapper) {
    var wrapperRect = mapWrapper.getBoundingClientRect();
    var width = wrapperRect.width, height = wrapperRect.height;
    var scale = width > 480 ? 2600 : 1600;
    var path = d3.geoPath();
    var projection = d3.geoConicConformal() // Lambert-93
        .center([2.454071, 46.279229]) // Center on France
        .scale(scale)
        .translate([width / 2, (height - 60) / 2]);
    path.projection(projection);

    var svg = d3.select('#home_map').append("svg")
        .attr("width", width)
        .attr("height", height);
    var regions = svg.append("g");
    var promises = [
        d3.json('/data/regions.json'),
        d3.json('/souscriptions/regions.json')
    ];
    activeRegion = d3.select(null);

    Promise.all(promises).then(function (values) {
        var regionsData = values[0];
        var subscriptionsData = values[1];

        mapFeatures = regions
            .selectAll("path")
            .data(regionsData.features)
            .enter().append("g").attr("class", "map_region");

        mapFeatures.append("path")
            .attr("id", function (d) {
                return d.properties.reference;
            })
            .attr("class", function (d) {
                return "region_path " + subscriptionLevel(d.properties.reference, subscriptionsData);
            })
            .attr("d", path)
            .on("click", focusOnRegion);
        mapFeatures.append("text").attr("class", "region_label")
            .html(function (d) {
                var count = subscriptionCount(d.properties.reference, subscriptionsData);
                var zoomedText = '<tspan class="zoomed_text" x="0" y="0" dy="-1.4em">' + d.properties.nom + '</tspan>';
                if (count > 0) {
                    return zoomedText + '<tspan class="map_text" x="0" y="0">' + formatAmount(count * 100) + '</tspan><tspan class="map_text" x="0" dy="1em">déclarés</tspan>';
                } else {
                    return zoomedText;
                }
            }).on("click", focusOnRegion);

        d3.selectAll("text.region_label").attr("transform", function (d, i) {
            var bbox = document.querySelector("#" + d.properties.reference).getBBox();
            return "translate(" + (bbox.x + bbox.width / 2) + " " + (bbox.y + bbox.height / 2) + ")";
        });
    });

    function focusOnRegion(d) {
        if (activeRegion.node() === this.parentElement) return resetMapZoom();
        activeRegion.classed("active", false);
        activeRegion = d3.select(this.parentElement).classed("active", true);

        var bounds = path.bounds(d),
            dx = bounds[1][0] - bounds[0][0],
            dy = bounds[1][1] - bounds[0][1],
            x = (bounds[0][0] + bounds[1][0]) / 2,
            y = (bounds[0][1] + bounds[1][1]) / 2,
            scale = .9 / Math.max(dx / width, dy / height),
            translate = [width / 2 - scale * x, height / 2 - scale * y];

        mapFeatures.transition()
            .duration(750)
            .style("opacity", function(feat) { return feat.properties.reference === d.properties.reference ? 1 : 0; })
            .attr("transform", "translate(" + translate + ")scale(" + scale + ")");
        setTimeout(function() {
            mapWrapper.classList.add('zoomed');
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
        var levels = [0, 5, 10, 25, 50, 100, 150, 200, 300, 10000];
        for (var i = 0; i < levels.length - 1; i++) {
            if (subscriptionsCount >= levels[i] && subscriptionsCount < levels[i + 1]) {
                return "level_" + i;
            }
        }
    }
}

function resetMapZoom(filter) {
    activeRegion.classed("active", false);
    activeRegion = d3.select(null);
    document.querySelector("#home_map").classList.remove('zoomed');

    mapFeatures.transition()
        .duration(750)
        .style("opacity", 1)
        .attr("transform", "");

    setTimeout(function() {
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
                        height: 170,
                        width: containerElt.innerWidth
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
                            x: 'label',
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
                            min: 0,
                            max: 5,
                            padding: 0
                        }
                    },
                    legend: {show: false},
                    interaction: {enabled: false},
                    bar: {
                        width: {
                            ratio: 0.7
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
            x: 'label',
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
    if (grp) {
        grp.setAttribute("transform", "translate(100.5,5.5)");
    }
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

function loadSubscriptions(container) {
    var rowsContainer = container.querySelector('tbody');
    var ajax = new XMLHttpRequest();
    ajax.open("GET", "/souscriptions.json", true);
    ajax.onload = function () {
        var resp = ajax.responseText;
        var subscriptionsData = JSON.parse(resp);
        for (var i = 0; i < subscriptionsData.length; i++) {
            rowsContainer.innerHTML += '<tr class="txtcenter">' +
                '<td>' + subscriptionsData[i].label + '</td>' +
                '<td>' + formatAmount(subscriptionsData[i].amount) + '</td>' +
                '<td>' + labelsByCategory[subscriptionsData[i].category] + '</td>' +
            '</tr>'
        }
    };
    ajax.send();
}