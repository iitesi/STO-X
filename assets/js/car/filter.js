$(document).ready(function() {
	// Get the total number of records before any filtering and set the numTotal value
	var numTotal = filterCar();
	$("#numTotal").text(numTotal);
	$("#numFiltered").text(numTotal);

	// Make In Policy an active state by default when page loads
	$("#btnPolicy").parent().addClass('active');

	// Get the total number of filtered records and set the numFiltered value
	var numFiltered = filterCar();
	$("#numFiltered").text(numFiltered);

	// Hide the filter box when page loads
	$(".filterselection").hide();

	// Show filter box when the vendor or car type button is clicked
	$("#btnCarVendor").click(function() { $(".filterselection").slideToggle(); });
	$("#btnCarCategory").click(function() { $(".filterselection").slideToggle(); });

	// Show filtered results when any filter criteria is clicked
	$(":checkbox").click(function() {
		var vendorCheckboxes = $("input[name='fltrVendor']");
		var carCheckboxes = $("input[name='fltrCategory']");
		$("#fltrVendorSelectAll").val(!vendorCheckboxes.is(':checked'));
		$("#fltrCarCategorySelectAll").val(!carCheckboxes.is(':checked'));
		$("#numFiltered").text(filterCar());
	});

	// In Policy (on/off)
	$("#btnPolicy").click(function() {
		if($("#btnPolicy").parent().hasClass('active')) {
			$("#btnPolicy").parent().removeClass('active');
		} else {
			$("#btnPolicy").parent().addClass('active');
		}
		$("#numFiltered").text(filterCar());
	});

	// Vendor Select/Clear All (on/off)
	/* $("#fltrVendorSelectAll").change(function() {
		if($(this).is(':checked')) {
			$(":checkbox[name=fltrVendor]").prop('checked', true);
		} else {
			$(":checkbox[name=fltrVendor]").prop('checked', false);
		}
	}); */

	// Car Select/Clear All (on/off)
	/* $("#fltrCarCategorySelectAll").change(function() {
		if($(this).is(':checked')) {
			$(":checkbox[name=fltrCategory]").prop('checked', true);
		} else {
			$(":checkbox[name=fltrCategory]").prop('checked', false);
		}
	}); */

	// Clear all filters
	$("#clearFilters").click(function() { 
		$("#numFiltered").text(filterCar('clearAll'));
		return false;
	});
});