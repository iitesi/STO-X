$(document).ready(function() {
	// Make In Policy an active state by default when page loads
	// $("#btnPolicy").parent().addClass('active');

	// Get the total number of records before any filtering
	var numTotal = filterCar();
	$("#numTotal").text(numTotal);

	// Hide the filter box when page loads
	$(".filterselection").hide();

	// Show filter box when any filter category is clicked
	$(".filterby").click(function() { $(".filterselection").slideToggle(); });

	// Show filtered results when any filter criteria is clicked
	$(":checkbox").click(function() { filterCar(); });

	// In Policy (on/off)
	$("#policy").change(function() {
		if($(this).is(':checked')) {
			$("#btnPolicy").parent().addClass('active');
		} else {
			$("#btnPolicy").parent().removeClass('active');
		}
	});

	// Vendor Select/Clear All (on/off)
	$("#fltrVendorSelectAll").change(function() {
		if($(this).is(':checked')) {
			$(":checkbox[name=fltrVendor]").prop('checked', true);
		} else {
			$(":checkbox[name=fltrVendor]").prop('checked', false);
		}
	});

	// Car Select/Clear All (on/off)
	$("#fltrCarCategorySelectAll").change(function() {
		if($(this).is(':checked')) {
			$(":checkbox[name=fltrCategory]").prop('checked', true);
		} else {
			$(":checkbox[name=fltrCategory]").prop('checked', false);
		}
	});

	// Clear all filters
	$("#clearFilters").click(function() { filterCar('clearAll'); });
});