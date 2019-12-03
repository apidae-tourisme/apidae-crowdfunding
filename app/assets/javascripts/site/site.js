document.addEventListener("DOMContentLoaded", function(event) {
    var mapWrapper = document.querySelector("#home_map");
    if (mapWrapper) {
        initMap(mapWrapper);
    }

});

function initMap(mapWrapper) {
    var wrapperRect = mapWrapper.getBoundingClientRect();
    var width = wrapperRect.width, height = wrapperRect.height;
    var path = d3.geoPath();
    var projection = d3.geoConicConformal() // Lambert-93
        .center([2.454071, 46.279229]) // Center on France
        .scale(2400)
        .translate([width / 2, height / 2]);
    path.projection(projection);

    var svg = d3.select('#home_map').append("svg")
        .attr("width", width)
        .attr("height", height);

    var regions = svg.append("g");

    var promises = [
        d3.json('/data/regions.json'),
        d3.json('/data/subscriptions.json')
    ];

    Promise.all(promises).then(function(values) {
        var regionsData = values[0];
        var subscriptionsData = values[1];

        var features = regions
            .selectAll("path")
            .data(regionsData.features)
            .enter().append("g").attr("class", "map_region");

        features.append("path")
            .attr("id", function (d) {
                return d.properties.reference;
            })
            .attr("class", function(d) { return "region_path " + subscriptionLevel(d.properties.reference, subscriptionsData.subscriptions);})
            .attr("d", path)
        features.append("text").attr("class", "region_label")
            .html(function(d) {
                var count = subscriptionCount(d.properties.reference, subscriptionsData.subscriptions);
                if (count > 0) {
                    return '<tspan x="0" y="0">' + (count * 100) + '€</tspan><tspan x="0" dy="1em">souscrits</tspan>';
                }
            });

        d3.selectAll("text.region_label").attr("transform", function(d, i) {
            var bbox = document.querySelector("#" + d.properties.reference).getBBox();
            return "translate(" + (bbox.x + bbox.width / 2) + " " + (bbox.y + bbox.height / 2) + ")";
        });
    });

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