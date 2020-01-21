function displayAlerts() {
    var alerts = document.querySelectorAll("#notice, #alert");
    if (alerts.length > 0) {
        setTimeout(function() {
            alerts[0].style = "transition: 1s; opacity: 0;";
        }, 3000);
    }
}