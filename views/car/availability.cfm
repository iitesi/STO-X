<br clear="both">
<cfoutput>
	#view('car/filter')#
	<div id="row#LCase(sCategory)#" class="car" style="width:#ArrayLen(StructKeyArray(session.searches[rc.Search_ID].stCarCategories))*100#px;">row#LCase(sCategory)#<br>

		<div style="width:150px;position:relative;float:left;">
			&nbsp;
		</div>

		<cfloop collection="#session.searches[rc.Search_ID].stCarVendors#" item="sVendor">
			
			<div id="#LCase(sVendor)#e" align="center" style="width:120px;border-left:1px solid ##CCC;position:relative;float:left;">
				<cfif ArrayFind(application.stAccounts[session.Acct_ID].aPreferredCar, sVendor)>
					<span class="medium blue bold">PREFERRED</span><br>
				<cfelseif application.stPolicies[session.searches[rc.nSearchID].nPolicyID].Policy_CarPrefRule
				AND NOT ArrayFind(application.stAccounts[session.Acct_ID].aPreferredCar, sVendor)>
					<img src="assets/img/policy0.png">
				</cfif>
				<img alt="#sVendor#" src="assets/img/cars/#sVendor#.png" style="padding-bottom:10px;">
			</div>

		</cfloop>

	</div>

	<br clear="all">

	<cfloop collection="#session.searches[rc.Search_ID].stCarCategories#" item="sCategory">
		<cfset stCar = session.searches[rc.Search_ID].stCars[sCategory]>
		<cfif NOT StructIsEmpty(stCar)>

			<div id="row#LCase(sCategory)#" class="car" style="width:#ArrayLen(StructKeyArray(session.searches[rc.Search_ID].stCarCategories))*100#px;">row#LCase(sCategory)#<br>

				<div style="width:150px;position:relative;float:left;">
					<cfif ArrayFind(application.stPolicies[session.searches[rc.nSearchID].nPolicyID].aCarSizes, sCategory)>
						<span class="medium blue bold">PREFERRED</span><br>
					<cfelseif application.stPolicies[session.searches[rc.nSearchID].nPolicyID].Policy_CarTypeRule EQ 1
					AND NOT ArrayFindNoCase(application.stPolicies[session.searches[rc.nSearchID].nPolicyID].aCarSizes, sCategory)>
						<img src="assets/img/policy0.png">
					</cfif>
					<span class="medium"><!--- #sCategory# ---></span><br>
					<img alt="#sCategory#" src="assets/img/cars/#Left(sCategory, Len(sCategory)-3)#.png" style="padding-top:10px;"><br>
				</div>

				<cfloop collection="#session.searches[rc.Search_ID].stCarVendors#" item="sVendor">
					<div id="#LCase(sCategory)##LCase(sVendor)#" align="center" style="width:120px;border-left:1px solid ##CCC;position:relative;float:left;">
						<cfif StructKeyExists(session.searches[rc.Search_ID].stCars[sCategory], sVendor)>
							<cfset stRate = session.searches[rc.Search_ID].stCars[sCategory][sVendor]>
							<!---#ArrayToList(stRate.aPolicies)#--->
							<input type="submit" class="button#stRate.Policy#policy" value="#(Left(stRate.EstimatedTotalAmount, 3) EQ 'USD' ? '$'&NumberFormat(Mid(stRate.EstimatedTotalAmount, 4)) : stRate.EstimatedTotalAmount)#">
						<cfelse>
							UNAVAILABLE
						</cfif>
					</div>
				</cfloop>

			</div>
			
		</cfif>
	</cfloop>
</cfoutput>
