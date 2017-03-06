$(document).ready(function() {
	// Get the total number of records before any filtering and set the numTotal value
	var view = Cookies.get('sto-view-pref')
	if(!view || view == 'grid') {
		// Default to grid-view
		$('.showGridView').addClass('active');
		$('.carResultPanel').addClass('grid-view');
		$('.carResultPanel').removeClass('list-view');
	} else {
		$('.showListView').addClass('active');
		$('.carResultPanel').addClass('list-view');
		$('.carResultPanel').removeClass('grid-view');
	}

	$('.carResultPanel').removeClass('hidden');

	$('.viewToggle button').click(function(ev){
		$('.viewToggle button').toggleClass('active');
		$('.carResultPanel').toggleClass('grid-view list-view');
		var viewSelected = $(ev.target).data('view');
		if(!viewSelected) viewSelected =  $(ev.target).parents('[data-view]').data('view')
		Cookies.set('sto-view-pref', viewSelected);
	});

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
