<div id="filterbar">
	<div>
		<div class="filterheader">Filter By</div>
		<button id="btnCarVendor">Vendor</button>
		<button id="btnCarCategory">Category</button>
		<button id="btnCarPrice">Price</button>
		<input type="checkbox" id="Policy" name="Policy"> <label for="Policy">In Policy</label>
	</div>
</div>
<cfoutput>
	<div id="VendorDialog" class="popup">
		<div class="popup-Vendor">
			<cfloop collection="#session.searches[rc.Search_ID].stCarVendors#" item="VendorCode">
				<div class="checkbox">
					<input id="Vendor#VendorCode#" type="checkbox" name="Vendor#VendorCode#" value="#VendorCode#" checked="checked" onclick="filtervendor();">
					<label for="Vendor#VendorCode#">#StructKeyExists(application.stCarVendors,VendorCode) ? application.stCarVendors[VendorCode] : 'No Car Vendor found'#</label>
				</div>
			</cfloop>
		</div>
	</div>
	<div id="CategoryDialog" class="popup">
		<div class="popup-category">
			<cfloop collection="#session.searches[rc.Search_ID].stCarCategories#" item="Category">
				<div class="checkbox">
					<input id="Cat#Category#" type="checkbox" checked="checked" name="Cat#Category#" value="#Category#" onclick="filtercategories();">
					<label for="Cat#category#">#Category#</label>
				</div>
			</cfloop>
		</div>
	</div>
</cfoutput>

<script type="application/javascript">
function filtercategories() {
	<cfoutput>
		<cfset lcategories = "" >
		<cfset numberofitems = 0 >
		<cfloop collection="#session.searches[rc.Search_ID].stCarCategories#" item="Category">
			<cfset lcategories = listappend(lcategories, #Category#) >
		</cfloop>
		var lcategories = '#lcategories#';
	</cfoutput>	
	lcategories = lcategories.split(',');	

	for (var t = 0; t < lcategories.length; t++) {
		var CategoryName = lcategories[t];
		var Categorymatch = 1;
		if ($("#Cat" + CategoryName + ":checked").val() == undefined) {
				Categorymatch = 0;
		}

		if (Categorymatch == 1) {
			$("#" + CategoryName ).show('fade');
		}
		else {
			$("#" + CategoryName ).hide('fade');		
		}
	}
	return false;
}

function filtervendor() {
	<cfoutput>
		<cfset lcategories = "" >
		<cfloop collection="#session.searches[rc.Search_ID].stCarCategories#" item="Category">
			<cfset lcategories = listappend(lcategories, #Category#) >
		</cfloop>
		var lcategories = '#lcategories#';
		<cfset lvendors = "" >
		<cfloop collection="#session.searches[rc.Search_ID].stCarVendors#" item="Vendor">
			<cfset lvendors = listappend(lvendors, #Vendor#) >
		</cfloop>
		var lvendors = '#lvendors#';
	</cfoutput>	
	lcategories = lcategories.split(',');	
	lvendors = lvendors.split(',');	

	for (var i = 0; i < lvendors.length; i++) {
		var VendorCode = lvendors[i];	
		var Vendormatch = 1;
		if ($("#Vendor" + VendorCode + ":checked").val() == undefined) {
			Vendormatch = 0;
		}

		for (var t = 0; t < lcategories.length; t++) {
			var CategoryName = lcategories[t];
			if (Vendormatch == 1) {
				$("#VenTitle" + VendorCode ).show('fade');
				$("#Ven" + VendorCode + CategoryName).show('fade');
			}
			else {
				$("#VenTitle" + VendorCode ).hide('fade');		
				$("#Ven" + VendorCode + CategoryName).hide('fade');
			}
		}
	}
	return false;
}

$(document).ready(function() {

	$( "#Policy" )
		.button()
		.change(function() {
			filtercar();
		});

	$( "#btnCarVendor" )
		.button({
			icons: {secondary: "ui-icon-triangle-1-s"}
		})
		.click(function() {
			$( "#VendorDialog" ).dialog( "open" );
		return false;
	});
	$( "#VendorDialog" ).dialog({
			autoOpen: false,
			show: "fade",
			hide: "fade",
			width: 525,
			title:	'Select your preferred car vendor',
			position: [100,120],
			modal: true,
			closeOnEscape: true,
			buttons: {
				"Cancel": function(){
					$( this ).dialog( "close" );
					return false;
				}
			}
		});
	$( "#btnCarCategory" )
		.button({
			icons: {secondary: "ui-icon-triangle-1-s"}
		})
		.click(function() {
			$( "#CategoryDialog" ).dialog( "open" );
		return false;
	});
	$( "#CategoryDialog" ).dialog({
			autoOpen: false,
			show: "fade",
			hide: "fade",
			width: 525,
			title:	'Select your preferred categories',
			position: [100,120],
			modal: true,
			closeOnEscape: true,
			buttons: {
				"Cancel": function(){
					$( this ).dialog( "close" );
					return false;
				}
			}
		});
	$( "#btnClass" )
		.button({
			icons: {secondary: "ui-icon-triangle-1-s"}
		})
		.click(function() {
			$( "#ClassDialog" ).dialog( "open" );
		return false;
	});
	
});
</script>
