<br clear="both">
<cfoutput>
	<div class="car" heigth="100%">
		<table width="100%">
		<tr>
			<td width="150"></td>
			<cfloop collection="#session.searches[rc.Search_ID].stCarVendors#" item="sVendor">
				<td heigth="100%" width="120" align="center" style="border-left:1px solid ##CCC">
					<cfif ArrayFind(application.stAccounts[session.Acct_ID].aPreferredCar, sVendor)>
						<span class="medium blue bold">PREFERRED</span><br>
					<cfelseif application.stPolicies[session.searches[rc.nSearchID].nPolicyID].Policy_CarPrefRule
					AND NOT ArrayFind(application.stAccounts[session.Acct_ID].aPreferredCar, sVendor)>
						<img src="assets/img/policy0.png">
					</cfif>
					<img alt="#sVendor#" src="assets/img/cars/#sVendor#.png" style="padding-bottom:10px;">
				</td>
			</cfloop>
		</tr>
		</table>
	</div>
	<br clear="all">
	<cfloop collection="#session.searches[rc.Search_ID].stCarCategories#" item="sCategory">
		<cfset stCar = session.searches[rc.Search_ID].stCars[sCategory]>
		<cfif NOT StructIsEmpty(stCar)>
			<div id="#sCategory#" class="car">
				<table width="100%" heigth="100%">
				<tr heigth="100%">
					<td width="150" align="center">
						<cfif ArrayFind(application.stPolicies[session.searches[rc.nSearchID].nPolicyID].aCarSizes, sCategory)>
							<span class="medium blue bold">PREFERRED</span><br>
						<cfelseif application.stPolicies[session.searches[rc.nSearchID].nPolicyID].Policy_CarTypeRule EQ 1
						AND NOT ArrayFindNoCase(application.stPolicies[session.searches[rc.nSearchID].nPolicyID].aCarSizes, sCategory)>
							<img src="assets/img/policy0.png">
						</cfif>
						<span class="medium">#sCategory#</span><br>
						<img alt="#sCategory#" src="assets/img/cars/#sCategory#.png" style="padding-top:10px;"><br>
					</td>
					<cfloop collection="#session.searches[rc.Search_ID].stCarVendors#" item="sVendor">
						<td heigth="100%" width="120" align="center" style="border-left:1px solid ##CCC">
							<cfif StructKeyExists(session.searches[rc.Search_ID].stCars[sCategory], sVendor)>
								<cfset stRate = session.searches[rc.Search_ID].stCars[sCategory][sVendor]>
								<!---#ArrayToList(stRate.aPolicies)#--->

								<input type="submit" class="button#stRate.Policy#policy" name="trigger" value="#(Left(stRate.EstimatedTotalAmount, 3) EQ 'USD' ? '$'&NumberFormat(Mid(stRate.EstimatedTotalAmount, 4)) : stRate.EstimatedTotalAmount)#">
							<cfelse>
								<cfif sCategory EQ 'MINI'>
									<a href="##" onClick="loadCarRates('#sCategory#', '#sVendor#')">See Rates</a>
								<cfelse>
									UNAVAILABLE
								</cfif>
							</cfif>
						</td>
					</cfloop>
				</tr>
				</table>
			</div>
			<br clear="all">
		</cfif>
	</cfloop>
</cfoutput>
<cfdump eval=session.searches[rc.Search_ID].stCars>