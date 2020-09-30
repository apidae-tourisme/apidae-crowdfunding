// Custom override to draw round corners in bar charts
// Also overrides d3 linear scale
c3.chart.internal.fn.generateDrawBar = function (barIndices, isSub) {
    var $$ = this;
    $$.y = $$.d3.scaleLinear().domain([0, 1]).range([0, 280]);
    var getPoints = $$.generateGetBarPoints(barIndices, isSub);
    return function (d, i) {
        var points = getPoints(d, i);
        // switch points since axis is rotated
        var indexX = 1;
        var indexY = 0;
        var borderRadius = 5;
        return 'M ' + points[0][indexX] + ',' + points[0][indexY] + ' ' +
            'L' + (points[1][indexX]-borderRadius) + ',' + points[1][indexY] + ' ' +
            'Q' + points[1][indexX] + ',' + points[1][indexY] + ' ' + points[1][indexX] + ',' + (points[1][indexY]+borderRadius) + ' ' +
            'L' + points[2][indexX] + ',' + (points[2][indexY]-borderRadius) + ' ' +
            'Q' + points[2][indexX] + ',' + points[2][indexY] + ' ' + (points[2][indexX]-borderRadius) + ',' + points[2][indexY] + ' ' +
            'L' + points[3][indexX] + ',' + points[3][indexY] + ' ' +
            'z';
    };
};
