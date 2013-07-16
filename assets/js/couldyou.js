$(document).ready(function(){

	$('#calendar1').fullCalendar({
        header: false,

        dayClick: function() {
			alert('a day has been clicked!');
		}
    })


})