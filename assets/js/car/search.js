$(document).ready(function(){
	$("button.btn" ).on( "click", function(event){ event.preventDefault() });
	$("#btnFormSubmit" ).on( "click", function(event){ 
		$('#displaySearchWindow').modal('hide');
		formSubmit( event, this );
	});

	var todaysDate = new Date();
	var calendarStartDate = dateFormat( new Date(), "mm/dd/yyyy" );

	var pickupVal = $("#car-pickup-date").val();
	var pickupDate = new Date(pickupVal);
	var dropoffVal = $("#car-dropoff-date").val();
	var dropoffDate = new Date(dropoffVal);

	$("#start-calendar-wrapper").datepicker({startDate: dateFormat(calendarStartDate, "mm/dd/yyyy")})
		.on("changeDate", function( event ){
			$("#car-pickup-date").val(event.date.format("mm/dd/yyyy", true));
			$("#end-calendar-wrapper").datepicker('setStartDate', event.date);
			$("#end-calendar-wrapper").datepicker('update', event.date.format("yyyy-mm-dd"));
		});

	$("#end-calendar-wrapper").datepicker({startDate: dateFormat(calendarStartDate, "mm/dd/yyyy")})
		.on("changeDate", function( event ){
			$("#car-dropoff-date").val(event.date.format("mm/dd/yyyy", true));
		});

	$("#start-calendar-wrapper").data('datepicker').date = null;
	$("#end-calendar-wrapper").data('datepicker').date = null;

	$("#start-calendar-wrapper").data('datepicker').setDate(pickupDate);
	$("#start-calendar-wrapper").data('datepicker').update();
	$("#end-calendar-wrapper").data('datepicker').setDate(dropoffDate);
	$("#end-calendar-wrapper").data('datepicker').update();

	$(".start-date").on("change", function() {
		var thisDate = new Date($(this).val());
		var originalCarDropoffDate = $("#car-dropoff-date").val();
		var carDropoffDate = new Date(originalCarDropoffDate);

		if (thisDate < todaysDate) {thisDate = todaysDate;}

		$("#car-pickup-date").val(thisDate.format("mm/dd/yyyy"));
		$("#start-calendar-wrapper").data('datepicker').setDate(thisDate);
		$("#start-calendar-wrapper").data('datepicker').update();

		if ((originalCarDropoffDate == '') || (thisDate > carDropoffDate)) {
			$("#car-dropoff-date").val(thisDate.format("mm/dd/yyyy"));
			$("#end-calendar-wrapper").data('datepicker').setDate(thisDate);
			$("#end-calendar-wrapper").data('datepicker').update();
		}
		else {
			$("#car-dropoff-date").val(carDropoffDate.format("mm/dd/yyyy"));
		}
	});

	$(".end-date").on("change", function() {
		var thisDate = new Date($(this).val());
		var originalCarPickupDate = $("#car-pickup-date").val();
		var carPickupDate = new Date(originalCarPickupDate);

		if (thisDate < todaysDate) {thisDate = todaysDate;}

		$("#car-dropoff-date").val(thisDate.format("mm/dd/yyyy"));
		$("#end-calendar-wrapper").data('datepicker').setDate(thisDate);
		$("#end-calendar-wrapper").data('datepicker').update();

		if ((originalCarPickupDate == '') || (carPickupDate > thisDate)) {
			$("#car-pickup-date").val(thisDate.format("mm/dd/yyyy"));
			$("#start-calendar-wrapper").data('datepicker').setDate(thisDate);
			$("#start-calendar-wrapper").data('datepicker').update();
		}
		else {
			$("#car-pickup-date").val(carPickupDate.format("mm/dd/yyyy"));
		}
	});

	$(".airport-select2" ).select2({
		data: airports,
		minimumInputLength: 2,
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
	// Purge any/all error validation being displayed and start anew
	var formErrors = new Array("car-location","car-pickup-date","car-dropoff-date");
	removeErrors(formErrors);
	var formErrors = new Array();
	var todaysDate = new Date();
	todaysDateFormatted = [(todaysDate.getMonth()+1).padLeft(),todaysDate.getDate().padLeft(),todaysDate.getFullYear()].join('/');

	//Build what text appears in the modal window based on what was selected in the form.
	setModalWindowText();

	//Disable the submit button to prevent duplicate search calls
	$("#btnFormSubmit" ).addClass("disabled");

	var formData = {};
	formData.searchID = $("#searchID").val();

	//Add the car values to the formData
	formData.car = 1;
	formData.carPickupAirport = $("#car-location").val();
	if ($("#car-location").val() == '') {formErrors.push("car-location");}
	formData.carPickupDate = $("#car-pickup-date").val();
	jsCarPickupDate = new Date($("#car-pickup-date").val());
	jsCarPickupDateNextDay = new Date(jsCarPickupDate);
	jsCarPickupDateNextDay.setDate(jsCarPickupDate.getDate()+1);
	jsCarPickupDateNextDayFormatted = [(jsCarPickupDateNextDay.getMonth()+1).padLeft(),jsCarPickupDateNextDay.getDate().padLeft(),jsCarPickupDateNextDay.getFullYear()].join('/');
	if (($("#car-pickup-date").val() == '') || (!isDate($("#car-pickup-date").val()))) {formErrors.push("car-pickup-date");}
	else if (jsCarPickupDate < todaysDate) {
		$("#car-pickup-date").val(todaysDateFormatted);
		$("#start-calendar-wrapper").data('datepicker').setDate(todaysDate);
		$("#start-calendar-wrapper").data('datepicker').update();
	}
	formData.carPickupTimeActual = $("#car-pickup-time").val();

	switch (formData.carPickupTimeActual) {
		case "Anytime":
			formData.carPickupTime = "00:00";
			break;
		case "Early Morning":
			formData.carPickupTime = "06:00";
			break;
		case "Late Morning":
			formData.carPickupTime = "10:00";
			break;
		case "Afternoon":
			formData.carPickupTime = "14:00";
			break;
		case "Evening":
			formData.carPickupTime = "18:00";
			break;
		case "Red Eye":
			formData.carPickupTime = "23:00";
			break;
		default:
			formData.carPickupTime = formData.carPickupTimeActual;
			break;
	}

	formData.carDropoffDate = $("#car-dropoff-date").val();
	jsCarDropoffDate = new Date($("#car-dropoff-date").val());
	if (($("#car-dropoff-date").val() == '') || (!isDate($("#car-dropoff-date").val()))) {formErrors.push("car-dropoff-date");}
	else if (jsCarDropoffDate < jsCarPickupDate) {
		$("#car-dropoff-date").val(jsCarPickupDateNextDayFormatted);
		$("#end-calendar-wrapper").data('datepicker').setDate(jsCarPickupDateNextDay);
		$("#end-calendar-wrapper").data('datepicker').update();
	}
	else if (jsCarDropoffDate < todaysDate) {
		$("#car-dropoff-date").val(todaysDateFormatted);
		$("#end-calendar-wrapper").data('datepicker').setDate(todaysDate);
		$("#end-calendar-wrapper").data('datepicker').update();
	}
	formData.carDropoffTimeActual = $("#car-dropoff-time").val();

	switch (formData.carDropoffTimeActual) {
		case "Anytime":
			formData.carDropoffTime = "00:00";
			break;
		case "Early Morning":
			formData.carDropoffTime = "06:00";
			break;
		case "Late Morning":
			formData.carDropoffTime = "10:00";
			break;
		case "Afternoon":
			formData.carDropoffTime = "14:00";
			break;
		case "Evening":
			formData.carDropoffTime = "18:00";
			break;
		case "Red Eye":
			formData.carDropoffTime = "23:00";
			break;
		default:
			formData.carDropoffTime = formData.carDropoffTimeActual;
			break;
	}

	console.log(formErrors);
	console.log(formData);
	/* $.ajax({
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
	}); */
};

displayErrors = function(formErrors) {
	for (var i = 0; i < formErrors.length; i++) {
		var thisField = eval("$('#" + formErrors[i] + "')");
		if (formErrors[i] == 'hotel-out-date') {
			var thisHiddenField = eval("$('#hotel-in-date_hidden')");
		}
		else {
			var thisHiddenField = eval("$('#" + formErrors[i] + "_hidden')");
		}
		thisField.addClass("highlight");
		thisHiddenField.removeClass("hidden");
	}
}

removeErrors = function(formErrors) {
	for (var i = 0; i < formErrors.length; i++) {
		if (formErrors[i].substring(0, 5) == 'multi') {
			for (var j = 1; j < 4; j++) {
				var thisField = eval("$('#" + formErrors[i] + j + "')");
				var thisHiddenField = eval("$('#" + formErrors[i] + j + "_hidden')");
				thisField.removeClass("highlight");
				thisHiddenField.addClass("hidden");
			}
		}
		else {
			var thisField = eval("$('#" + formErrors[i] + "')");
			var thisHiddenField = eval("$('#" + formErrors[i] + "_hidden')");
			thisField.removeClass("highlight");
			thisHiddenField.addClass("hidden");
		}
	}
}

Number.prototype.padLeft = function(base,chr){
	var  len = (String(base || 10).length - String(this).length)+1;
	return len > 0? new Array(len).join(chr || '0')+this : this;
}

function isDate(value) {
    try {
    	value = value.split("/");

        var MonthIndex = value[0];
        var DayIndex = value[1]; 
        var YearIndex = value[2];
        var OK = true;
        if (!(MonthIndex.length == 1 || MonthIndex.length == 2)) {
            OK = false;
        }
        if (OK && !(DayIndex.length == 1 || DayIndex.length == 2)) {
            OK = false;
        }
        if (OK && YearIndex.length != 4) {
            OK = false;
        }

        if (OK) {
            var Month = parseInt(MonthIndex, 10);
            var Day = parseInt(DayIndex, 10);
            var Year = parseInt(YearIndex, 10);
 
            if (OK = (Year >= new Date().getFullYear())) {
                if (OK = (Month <= 12 && Month > 0)) {
                    var LeapYear = (((Year % 4) == 0) && ((Year % 100) != 0) || ((Year % 400) == 0));   
                    
                    if(OK = Day > 0) {
                        if (Month == 2) {  
                            OK = LeapYear ? Day <= 29 : Day <= 28;
                        } 
                        else {
                            if ((Month == 4) || (Month == 6) || (Month == 9) || (Month == 11)) {
                                OK = Day <= 30;
                            }
                            else {
                                OK = Day <= 31;
                            }
                        }
                    }
                }
            }
        }
        return OK;
    }
    catch (e) {
        return false;
    }
}

setModalWindowText = function(){
	//If car is checked, add car-related text to the modal window.
	$( "#waitModalBody" ).append("<h3>CAR</h3>");
	$( "#waitModalBody" ).append("<p>We are finding cars available at " + $("#car-location").val() + " " + $("#car-pickup-date").val() + " - " + $("#car-dropoff-date").val() + ".<p>");
};