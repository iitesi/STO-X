<br clear="both">
<cfset asubcategories = ['CAR', 'VAN', 'SUV'] >
<cfoutput>
	#View('car/filter')#
	<br>
	<br clear="all">
	<div class="car" heigth="100%">
		<table width="100%">
		<tr>
			<td width="150"></td>
			<cfloop collection="#session.searches[rc.Search_ID].stCarVendors#" item="sVendor">
				<td heigth="100%" width="120" align="center" style="border-left:1px solid ##CCC">
					<div id=VenTitle#sVendor#>
						<cfif ArrayFind(application.stAccounts[session.Acct_ID].aPreferredCar, sVendor)>
							<span class="medium blue bold">PREFERRED</span><br>
						<cfelseif application.stPolicies[session.searches[rc.nSearchID].nPolicyID].Policy_CarPrefRule
						AND NOT ArrayFind(application.stAccounts[session.Acct_ID].aPreferredCar, sVendor)>
							<img src="assets/img/policy0.png">
						</cfif>
						<img alt="#sVendor#" src="assets/img/cars/#sVendor#.png" style="padding-bottom:10px;">
					</div>
				</td>
				</div>
			</cfloop>
		</tr>
		</table>
	</div>
	<br clear="all">
	<cfloop collection="#session.searches[rc.Search_ID].stCarCategories#" item="sCategory">
		<cfset stCar = session.searches[rc.Search_ID].stCars[sCategory]>
		<cfif NOT StructIsEmpty(stCar)>
			<cfloop collection="#session.searches[rc.Search_ID].stCars[sCategory]#" item="ssubCategory">
				<cfif ArrayFindNoCase(asubcategories, ssubCategory)>
					<div id="#sCategory##UCase(ssubCategory)#" class="car">
						<table width="100%" heigth="100%">
						<tr heigth="100%">
							<td width="150" align="center">
								<cfif ArrayFindNoCase(application.stPolicies[session.searches[rc.nSearchID].nPolicyID].aCarSizes, sCategory)>
									<span class="medium blue bold">PREFERRED</span><br>
								<cfelseif application.stPolicies[session.searches[rc.nSearchID].nPolicyID].Policy_CarTypeRule EQ 1
								AND NOT ArrayFindNoCase(application.stPolicies[session.searches[rc.nSearchID].nPolicyID].aCarSizes, sCategory)>
									<img alt="" src="assets/img/policy0.png">
								</cfif>
								<span class="medium">#sCategory#<br>#ssubCategory#</span><br>
								<img alt="#sCategory#" src="assets/img/cars/#sCategory#.png" style="padding-top:10px;"><br>
							</td>
							<cfloop collection="#session.searches[rc.Search_ID].stCarVendors#" item="sVendor">
								<td heigth="100%" width="120" align="center" style="border-left:1px solid ##CCC">
									<div id=Ven#sVendor##sCategory##UCase(ssubCategory)#>
										<cfif StructKeyExists(session.searches[rc.Search_ID].stCars[sCategory][ssubCategory], sVendor)>
											<cfset stRate = session.searches[rc.Search_ID].stCars[sCategory][ssubCategory][sVendor]>
									<!---#ArrayToList(stRate.aPolicies)#--->
		
											<input type="submit" class="button#stRate.Policy#policy" name="trigger" value="#(Left(stRate.EstimatedTotalAmount, 3) EQ 'USD' ? '$'&NumberFormat(Mid(stRate.EstimatedTotalAmount, 4)) : stRate.EstimatedTotalAmount)#">
										<cfelse>
											UNAVAILABLE
										</cfif>
									</div>
								</td>
							</cfloop>
						</tr>
						</table>
						<br clear="all">
					 </div>
				 </cfif>
			 </cfloop>
		</cfif>
	</cfloop>
</cfoutput>
				<br clear="all">
<cfdump eval=application.stPolicies[session.searches[rc.nSearchID].nPolicyID].aCarSizes>
<cfdump eval=session.searches[rc.Search_ID].stCarVendors>
<cfdump eval=session.searches[rc.Search_ID].stCarCategories>
<cfdump eval=session.searches[rc.Search_ID].stCars>