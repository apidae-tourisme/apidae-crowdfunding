const colorsByCategory = {
    ia: '#F97E7E',
    ip: '#FFC302',
    ct: '#74C5EA',
    at: '#F7E337',
    sr: '#FB71A7',
    fs: '#9D9D9C',
    sa: '#BDD07B',
    sp: '#00B1C6'
};

const labelsByCategory = {
    ia: "Investisseurs actifs",
    ip: "Investisseurs passifs",
    ct: "Coordinateurs territoriaux",
    at: "Acteurs territoriaux",
    sr: "Soutiens du réseau",
    fs: "Fournisseurs de services",
    sa: "Salariés de la SCIC",
    sp: "Socio-professionnels"
};

var rankingsChart, rankingsData;

document.addEventListener("DOMContentLoaded", function (event) {
    var mapWrapper = document.querySelector("#home_map");
    if (mapWrapper) {
        initMap(mapWrapper);
    }
    var chartsWrapper = document.querySelector("#home_charts");
    if (chartsWrapper) {
        initRankingsChart("rankings");
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
    var path = d3.geoPath();
    var projection = d3.geoConicConformal() // Lambert-93
        .center([2.454071, 46.279229]) // Center on France
        .scale(2600)
        .translate([width / 2, (height - 60) / 2]);
    path.projection(projection);

    var svg = d3.select('#home_map').append("svg")
        .attr("width", width)
        .attr("height", height);
    var regions = svg.append("g");
    var promises = [
        d3.json('/data/regions.json'),
        d3.json('/data/regions_subscriptions.json')
    ];
    var active = d3.select(null);
    var features;

    Promise.all(promises).then(function (values) {
        var regionsData = values[0];
        var subscriptionsData = values[1];

        features = regions
            .selectAll("path")
            .data(regionsData.features)
            .enter().append("g").attr("class", "map_region");

        features.append("path")
            .attr("id", function (d) {
                return d.properties.reference;
            })
            .attr("class", function (d) {
                return "region_path " + subscriptionLevel(d.properties.reference, subscriptionsData);
            })
            .attr("d", path)
            .on("click", focusOnRegion);
        features.append("text").attr("class", "region_label")
            .html(function (d) {
                var count = subscriptionCount(d.properties.reference, subscriptionsData);
                if (count > 0) {
                    return '<tspan x="0" y="0">' + (count * 100) + '€</tspan><tspan x="0" dy="1em">souscrits</tspan>';
                }
            }).on("click", focusOnRegion);

        d3.selectAll("text.region_label").attr("transform", function (d, i) {
            var bbox = document.querySelector("#" + d.properties.reference).getBBox();
            return "translate(" + (bbox.x + bbox.width / 2) + " " + (bbox.y + bbox.height / 2) + ")";
        });
    });

    function focusOnRegion(d) {
        if (active.node() === this.parentElement) return reset();
        mapWrapper.classList.add('zoomed');
        active.classed("active", false);
        active = d3.select(this.parentElement).classed("active", true);

        var bounds = path.bounds(d),
            dx = bounds[1][0] - bounds[0][0],
            dy = bounds[1][1] - bounds[0][1],
            x = (bounds[0][0] + bounds[1][0]) / 2,
            y = (bounds[0][1] + bounds[1][1]) / 2,
            scale = .9 / Math.max(dx / width, dy / height),
            translate = [width / 2 - scale * x, height / 2 - scale * y];

        features.transition()
            .duration(750)
            .style("opacity", function(feat) { return feat.properties.reference === d.properties.reference ? 1 : 0; })
            .attr("transform", "translate(" + translate + ")scale(" + scale + ")");
    }

    function reset() {
        active.classed("active", false);
        active = d3.select(null);
        mapWrapper.classList.remove('zoomed');

        features.transition()
            .duration(750)
            .style("opacity", 1)
            .attr("transform", "");
    }


    function subscriptionCount(ref, subscriptions) {
        for (var i = 0; i < subscriptions.length; i++) {
            if (subscriptions[i].reference === ref) {
                return subscriptions[i].count;
            }
        }
    }

    function subscriptionLevel(ref, subscriptions) {
        return countLevel(subscriptionCount(ref, subscriptions));
    }

    function countLevel(subscriptionsCount) {
        var levels = [0, 5, 10, 25, 50, 100, 150, 200, 300, 1000];
        for (var i = 0; i < levels.length - 1; i++) {
            if (subscriptionsCount >= levels[i] && subscriptionsCount < levels[i + 1]) {
                return "level_" + i;
            }
        }
    }
}

function toggleRankFilter(filter, btn) {
    if (!btn.classList.contains('active')) {
        if (filter === 'all') {
            initRankingsChart("rankings");
        } else if (filter === 'public') {
            initRankingsChart("rankings_public");
        } else if (filter === 'private') {
            initRankingsChart("rankings_private");
        }
        document.querySelector('#rank_filters button.active').classList.remove('active');
        btn.classList.add('active');
    }
}

function initRankingsChart(rankingType) {
    var ajax = new XMLHttpRequest();
    ajax.open("GET", "/data/" + rankingType + ".json", true);
    ajax.onload = function () {
        var resp = ajax.responseText;
        rankingsData = JSON.parse(resp);
        if (rankingsChart) {
            rankingsChart.load({
                json: rankingsData,
                keys: {
                    x: 'label',
                    value: ['value']
                }
            });
        } else {
            var containerElt = document.querySelector('#rank_chart');
            rankingsChart = c3.generate({
                bindto: '#rank_chart',
                size: {
                    height: 150,
                    width: containerElt.innerWidth + 100
                },
                data: {
                    json: rankingsData,
                    type: 'bar',
                    labels: {
                        format: function (v) {
                            return v + '€';
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
                        tick: {multiline: false}
                    },
                    y: {show: false}
                },
                legend: {show: false},
                interaction: {enabled: false},
                bar: {
                    width: {
                        ratio: 0.7
                    },
                    space: 0.1
                }
            });
        }
    };
    ajax.send();
}

function initPieChart() {
    var ajax = new XMLHttpRequest();
    ajax.open("GET", "/data/proportions.json", true);
    ajax.onload = function () {
        var resp = ajax.responseText;
        var proportionsData = JSON.parse(resp);
        var chart = c3.generate({
            bindto: '#pie_chart',
            size: {
                height: 240
            },
            data: {
                json: proportionsData,
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
                        return value / 100;
                    }
                }
            }
        });

        d3.select('#pie_chart_wrapper').selectAll('div.legend_item')
            .data(Object.keys(proportionsData))
            .enter().append('div')
            .attr('class', 'legend_item w33')
            .attr('data-id', function (id) { return id; })
            .html(function (id) {
                return '<p class="txtleft flex-container--row lh"><span class="fw500" style="color: ' + colorsByCategory[id] + ';">' + proportionsData[id] + '€</span>' +
                    '<span class="txt--white item-fluid">' + labelsByCategory[id] + '</span></p>';
            })
            .on('mouseover', function (id) {
                chart.focus(id);
            })
            .on('mouseout', function (id) {
                chart.revert();
            })
            .on('click', function (id) {
                chart.toggle(id);
            });
    };
    ajax.send();
}

function loadSubscriptions(container) {
    var rowsContainer = container.querySelector('tbody');
    var ajax = new XMLHttpRequest();
    ajax.open("GET", "/data/subscriptions.json", true);
    ajax.onload = function () {
        var resp = ajax.responseText;
        var subscriptionsData = JSON.parse(resp);
        for (var i = 0; i < subscriptionsData.length; i++) {
            rowsContainer.innerHTML += '<tr class="txtcenter">' +
                '<td>' + subscriptionsData[i].label + '</td>' +
                '<td>' + subscriptionsData[i].value + '€</td>' +
                '<td>' + labelsByCategory[subscriptionsData[i].category] + '</td>' +
            '</tr>'
        }
    };
    ajax.send();
}