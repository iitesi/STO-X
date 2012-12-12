<div id="filterbar">
	<div>
		<div class="filterheader">Filter By</div>
	</div>
</div>
<ul id="nav">
	<table>
	<tr>
<!---
VENDORS
--->		<td>
			<li>
				<input type="checkbox" id="btnCarVendor" name="btnCarVendor"> <label for="btnCarVendor">Vendors</label>
				<ul>
					<cfoutput>
						<cfloop collection="#session.searches[rc.Search_ID].stCarVendors#" item="VendorCode">
							<li><input id="btnVendor#LCase(VendorCode)#" type="checkbox" name="Vendor#VendorCode#" value="#VendorCode#" checked="checked" onClick="filterCar()"> <label for="btnVendor#LCase(VendorCode)#">#StructKeyExists(application.stCarVendors, VendorCode) ? application.stCarVendors[VendorCode] : 'No Car Vendor found'#</label></li>
						</cfloop>
					</cfoutput>
				</ul>
			</li>
		</td>

<!---
CATEGORIES
--->		<td>
			<li>
				<input type="checkbox" id="btnCarCategory" name="btnCarCategory"> <label for="btnCarCategory">Categories</label>
				<ul>
					<li>
					<table width="400px">
					<tr>
						<td width="33%"><strong>Car</strong></td>
						<td width="33%"><strong>Van</strong></td>
						<td width="33%"><strong>SUV</strong></td>
					</tr>
					<tr>
					<cfoutput>
						<cfset temp = ''>
						<cfloop collection="#session.searches[rc.Search_ID].stCarCategories#" item="sCategory">
							<cfif temp NEQ Right(sCategory, 3)>
								<cfif temp NEQ ''>
									</td>
								</cfif>
								<td valign="top">
								<cfset temp = Right(sCategory, 3)>
							</cfif>
							<input id="btnCategory#LCase(sCategory)#" type="checkbox" checked="checked" name="sCategory" value="#sCategory#" onClick="filterCar()"> <label for="btnCategory#LCase(sCategory)#">#Left(sCategory, Len(sCategory)-3)#</label><br>
						</cfloop>
						</td>
					</cfoutput>
					</tr>
					</table>
					</li>
				</ul>
			</li>
		</td>
<!---
POLICY
--->
		<td>
			<input type="checkbox" id="Policy" name="Policy" checked> <label for="Policy">In Policy</label>
		</td>
	</tr> 
	</table>
</ul>
<cfset stPolicy = application.stPolicies[session.searches[rc.nSearchID].nPolicyID]>
<cfset stAccount = application.stAccounts[session.Acct_ID]>
<script type="application/javascript">

$(document).ready(function() {
	$( "#btnCarVendor" ).button().click(function() { filterCar(); });
	$( "#btnCarCategory" ).button().click(function() { filterCar(); });
	$( "#Policy" ).button().change(function() { filterCar(); });
	filterCar();
});
<cfoutput>
	var carresults = [
		<cfset nCount = 0>
		<cfloop collection="#session.searches[rc.Search_ID].stCarCategories#" item="sCategory">
			<cfloop collection="#session.searches[rc.Search_ID].stCarVendors#" item="sVendor">
				<cfif nCount NEQ 0>,</cfif>
				<cfset nCount++>
				<cfif structKeyExists(session.searches[rc.Search_ID].stCars[sCategory], sVendor)>
					[#session.searches[rc.Search_ID].stCars[sCategory][sVendor].sJavascript#]
				<cfelse>
					['#LCase(sCategory)##LCase(sVendor)#','#LCase(sCategory)#','#LCase(sVendor)#',0,0]
				</cfif>
			</cfloop>
		</cfloop>];

	var carcategories = [
		<cfset nCount = 0>
		<cfloop collection="#session.searches[rc.Search_ID].stCarCategories#" item="sCategory">
			<cfif nCount NEQ 0>,</cfif>
			<cfset nCount++>
			['#LCase(sCategory)#',#(stPolicy.Policy_CarTypeRule EQ 1 AND NOT ArrayFindNoCase(stPolicy.aCarSizes, sCategory) ? 0 : 1)#]
		</cfloop>];

	var carvendors = [
		<cfset nCount = 0>
		<cfloop collection="#session.searches[rc.Search_ID].stCarVendors#" item="sVendor">
			<cfif nCount NEQ 0>,</cfif>
			<cfset nCount++>
			['#LCase(sVendor)#',#(stPolicy.Policy_CarPrefRule EQ 1 AND NOT ArrayFindNoCase(stAccount.aPreferredCar, sVendor) ? 0 : 1)#]
		</cfloop>];

</cfoutput>



</script>
