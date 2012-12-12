<div id="filterbar">
	<div>
		<div class="filterheader">Filter By</div>
	</div>
</div>
<ul id="nav">
	<table>
	<tr>
		<td>
		<li>
			<input type="checkbox" id="btnCarVendor" name="btnCarVendor">
			<label for="btnCarVendor">
				Vendors
			</label>
			<ul>
				<cfoutput>
					<cfloop collection="#session.searches[rc.Search_ID].stCarVendors#" item="VendorCode">
						<div class="checkbox">
							<input id="Vendor#LCase(VendorCode)#" type="checkbox" name="Vendor#VendorCode#" value="#VendorCode#" checked="checked" onClick="filterCar()">
							<label for="#LCase(VendorCode)#">
								#StructKeyExists(application.stCarVendors, VendorCode) ? application.stCarVendors[VendorCode] : 'No Car Vendor found'#
							</label>
						</div>
					</cfloop>
				</cfoutput>
			</ul>
		</li>
		</td>
		<td>
		<li>
			<input type="checkbox" id="btnCarCategory" name="btnCarCategory">
			<label for="btnCarCategory">
				Categories
			</label>
			<ul>
				<cfoutput>
					<cfloop collection="#session.searches[rc.Search_ID].stCarCategories#" item="sCategory">
						<div class="checkbox">
							<input id="Category#LCase(sCategory)#" type="checkbox" checked="checked" name="sCategory" value="#sCategory#" onClick="filterCar()">
							<label for="#LCase(sCategory)#">
								#sCategory#
							</label>
						</div>
					</cfloop>
				</cfoutput>
			</ul>
		</li>
		</td>
	</tr> 
	</table>
</ul>

<script type="application/javascript">

$(document).ready(function() {
	$( "#btnCarVendor" )
		.button()
		.click(function() {
			filterCar();
		return false;
	});
	$( "#btnCarCategory" )
		.button()
		.click(function() {
			filterCar();
		return false;
	});
});

var carresults = [<cfset nCount = 0><cfloop collection="#session.searches[rc.Search_ID].stCarCategories#" item="sCategory"><cfloop collection="#session.searches[rc.Search_ID].stCarVendors#" item="sVendor"><cfif nCount NEQ 0>,</cfif><cfset nCount++><cfif structKeyExists(session.searches[rc.Search_ID].stCars[sCategory], sVendor)><cfoutput>[#session.searches[rc.Search_ID].stCars[sCategory][sVendor].sJavascript#]</cfoutput><cfelse><cfoutput>['#LCase(sCategory)##LCase(sVendor)#','#LCase(sCategory)#','#LCase(sVendor)#',0,0]</cfoutput></cfif></cfloop></cfloop>];
var carcategories = [<cfset nCount = 0><cfloop collection="#session.searches[rc.Search_ID].stCarCategories#" item="sCategory"><cfif nCount NEQ 0>,</cfif><cfset nCount++><cfoutput>'#LCase(sCategory)#'</cfoutput></cfloop>];
var carvendors = [<cfset nCount = 0><cfloop collection="#session.searches[rc.Search_ID].stCarVendors#" item="sVendor"><cfif nCount NEQ 0>,</cfif><cfset nCount++><cfoutput>'#LCase(sVendor)#'</cfoutput></cfloop>];

function filterCar() {
	for (loopcnt = 0; loopcnt <= (carcategories.length-1); loopcnt++) {
		var category = carcategories[loopcnt];
		if ($( "#Category" + category ).is(':checked') == false) {
			$( '#row' + category ).hide();
		}
		else {
			for (loopcnt = 0; loopcnt <= (carresults.length-1); loopcnt++) {
				var car = carresults[loopcnt];
				console.log(car)
				if ($( "#Vendor" + car[2] ).is(':checked') == false) {
					$( "#" + car[0] ).hide();
					$( "#" + car[2] + 'e' ).hide();
				}
			}
			$( '#row' + category ).show();
		}
	}
	return false;
}
</script>
