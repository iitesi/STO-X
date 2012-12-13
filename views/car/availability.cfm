<br clear="both">
<cfoutput>
	#view('car/filter')#
	<div class="car">
		<table>
		<tr>
			<td>
				<div style="width:150px;position:relative;float:left;">
					&nbsp;
				</div>
			</td>
			<cfloop collection="#session.searches[rc.Search_ID].stCarVendors#" item="sVendor">
				<td>
				<div id="vendor#LCase(sVendor)#" align="center" style="width:120px;border-left:1px solid ##CCC;position:relative;float:left;">
					<cfif ArrayFind(application.stAccounts[session.Acct_ID].aPreferredCar, sVendor)>
						<span class="medium blue bold">PREFERRED</span><br>
					</cfif>
					<img alt="#sVendor#" src="assets/img/cars/#sVendor#.png" style="padding-bottom:10px;">
				</div>
				</td>
			</cfloop>
		</tr>
		</table>
	</div>

	<br clear="all">

	<cfloop collection="#session.searches[rc.Search_ID].stCarCategories#" item="sCategory">
		<cfset stCar = session.searches[rc.Search_ID].stCars[sCategory]>
		<cfif NOT StructIsEmpty(stCar)>

			<div id="row#LCase(sCategory)#" class="car">
				<table>
				<tr>
					<td>
						<div style="width:150px;position:relative;float:left;">
							<cfif ArrayFind(application.stPolicies[session.searches[rc.nSearchID].nPolicyID].aCarSizes, sCategory)>
								<span class="medium blue bold">PREFERRED</span><br>
							</cfif>
							<span class="medium"><!--- #sCategory# ---></span><br>
							<img alt="#sCategory#" src="assets/img/cars/#sCategory#.jpg" style="padding-top:10px;" width="127"><br>
						</div>
					</td>

					<cfloop collection="#session.searches[rc.Search_ID].stCarVendors#" item="sVendor">
						<td>
							<div id="#LCase(sCategory)##LCase(sVendor)#" align="center" style="width:120px;border-left:1px solid ##CCC;position:relative;float:left;">
								<cfif StructKeyExists(session.searches[rc.Search_ID].stCars[sCategory], sVendor)>
									<cfset stRate = session.searches[rc.Search_ID].stCars[sCategory][sVendor]>
									<cfif stRate.Corporate>
										CORPORATE
									</cfif>
									<input type="submit" class="button#stRate.Policy#policy" value="#(Left(stRate.EstimatedTotalAmount, 3) EQ 'USD' ? '$'&NumberFormat(Mid(stRate.EstimatedTotalAmount, 4)) : stRate.EstimatedTotalAmount)#">
								<cfelse>
									UNAVAILABLE
								</cfif>
							</div>
						</td>
					</cfloop>
				</tr>
				</table>
			</div>
			
		</cfif>
	</cfloop>
</cfoutput>