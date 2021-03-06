$(document).ready(function() {
	// Get the total number of records before any filtering and set the numTotal value
	var numTotal = filterCar();  
	$("#numTotal").text(numTotal);
	$("#numFiltered").text(numTotal);

	// Make In Policy an active state by default when page loads
	// If Account is configured as carInPolicyDefault = 1
	if (carInPolicyDefault == 1) {
		$("#btnPolicy").parent().addClass('active');
	}
	// Get the total number of filtered records and set the numFiltered value
	var numFiltered = filterCar();
	$("#numFiltered").text(numFiltered);

	// Hide the filter box when page loads
	$(".filterselection").hide();
	$('#vendors, #carTypes, #locations').hide();

	// Show filter box when the vendor or car type button is clicked
	 $("#btnCarVendor").click(function() { $('#vendors').show(); });
	$("#btnCarCategory").click(function() { $('#carTypes').show(); });
	$("#btnLocation").click(function() { $('#locations').show(); });
	
	$('.carFilterBy').click(function() { $('.filterselection').slideToggle({
			complete: function() {
				if(!$('.filterselection').is(':visible')) {
					$('#vendors, #carTypes, #locations').hide();
				};
			}
		});
	});
 
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

	 $(".closewell").on("click", function() {
		$(this).parent().parent().slideUp();
		$('#vendors, #carTypes, #locations').hide();
	}); 
});