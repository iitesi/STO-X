$(document).ready(function(){
	$("button.btn" ).on( "click", function(event){ event.preventDefault() });
	$("#btnFormSubmit" ).on( "click", function(event){ 
		$('#displaySearchWindow').modal('hide');
		formSubmit( event, this );
	});

	var calendarStartDate = dateFormat( new Date(), "mm/dd/yyyy" );
	var pickupVal = $("#car-pickup-date").val();
	var pickupDate = new Date(pickupVal);
	var dropoffVal = $("#car-dropoff-date").val();
	var dropoffDate = new Date(dropoffVal);

	$("#start-calendar-wrapper" ).datepicker( { startDate: calendarStartDate } )
		.on( "changeDate", function( event ){
			$("#car-pickup-date" ).val( event.date.format( "mmm dd, yyyy", true ) );
			$("#end-calendar-wrapper" ).datepicker('setStartDate', event.date );
			$("#end-calendar-wrapper" ).datepicker('update', event.date.format( "yyyy-mm-dd" ) );
			$("#car-dropoff-date" ).val( '' );
		});

	$("#end-calendar-wrapper" ).datepicker( { startDate: calendarStartDate } )
		.on( "changeDate", function( event ){
			$("#car-dropoff-date" ).val( event.date.format( "mmm dd, yyyy", true ) );
		});

	$("#start-calendar-wrapper" ).data( 'datepicker' ).setDate( pickupDate );
	$("#start-calendar-wrapper" ).data( 'datepicker' ).update();
	$("#end-calendar-wrapper" ).data( 'datepicker' ).setDate( dropoffDate );
	$("#end-calendar-wrapper" ).data( 'datepicker' ).update();

	/* $("#start-calendar-wrapper").datepicker("setDate", pickupDate);
	$("#end-calendar-wrapper").datepicker("setDate", dropoffDate); */

	$(".airport-select2" ).select2({
		data: airports,
		width: "100%",
		sortResults: sortResults
	});

	// This makes drop navigation items update its display based on the item selected (nav bar items)
	$("ul.nav li ul li a").on( "click", function(){
		var selectedOption = $( this ).attr( "data-value" );
		var menuRoot = $( this ).parents( "li.dropdown" );
		$( "a.dropdown-toggle", menuRoot ).html( selectedOption  + ' <b class="caret"></b>' );
		$( "a.dropdown-toggle", menuRoot ).attr( "data-value", selectedOption );

	});

	// This makes any button group update its display based on the item selected
	$("div.btn-group ul.dropdown-menu li a" ).on( "click", function(){
		var group = $( this ).parents( ".btn-group" );
		$(".btn:first-child", group ).text( $(this).text() );
		$(".btn:first-child", group).val( $(this).attr( "data-value" ) );
	});
});

sortResults = function(results, container, query) {
	if (query.term) {
		for (var i = 0; i < results.length; i++) {
			if( results[i].id.toUpperCase() == query.term.toUpperCase() ){
				results.move( i, 0 );
			}
		}
	}

	return results;
};

Array.prototype.move = function (old_index, new_index) {
	if (new_index >= this.length) {
		var k = new_index - this.length;
		while ((k--) + 1) {
			this.push(undefined);
		}
	}
	this.splice(new_index, 0, this.splice(old_index, 1)[0]);
};

formSubmit = function( event ){
	event.preventDefault();

	//Build what text appears in the modal window based on what was selected in the form.
	setModalWindowText();

	//TODO: Implement form validation rules

	//Disable the submit button to prevent duplicate search calls
	$("#btnFormSubmit" ).addClass( "disabled" );

	var formData = {};
	formData.searchID = $("#searchID" ).val();

	//Add the car values to the formData
	formData.car = 1;
	formData.carPickupAirport = $("#car-location" ).val();
	formData.carPickupDate = $("#car-pickup-date" ).val();
	formData.carPickupTime = $("#car-pickup-time" ).val();
	formData.carDropoffDate = $("#car-dropoff-date" ).val();
	formData.carDropoffTime = $("#car-dropoff-time" ).val();

	$.ajax({
		type: "POST",
		url: "/search/RemoteProxy.cfc?method=saveSearch",
		data: formData,
		success: function( response ){
			if( response.success == true ){
				window.location = "/booking/index.cfm?action=car.availability&searchId=" + formData.searchID + "&requery=true";
			}else{
				//TODO: Process any errors returned from the server

				//Enable the submit button since this search wasn't saved
				$("#btnFormSubmit" ).addClass( "enabled" );
			}
		},
		dataType: "json"
	});
};

setModalWindowText = function(){
	//If car is checked, add car-related text to the modal window.
	$( "#waitModalBody" ).append("<h3>CAR</h3>");
	$( "#waitModalBody" ).append("<p>We are finding cars available at " + $("#car-location").val() + " " + $("#car-pickup-date").val() + " - " + $("#car-dropoff-date").val() + ".<p>");
};