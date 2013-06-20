<cfif (rc.Filter.getAir() AND structKeyExists(session.searches[rc.SearchID].stItinerary, 'Air'))
OR NOT rc.Filter.getAir()>
	<div class="page-header">
		<cfoutput>
			<h1><a href="#buildURL('car.availability&SearchID=#rc.SearchID#')#">#UCase(rc.Filter.getCarHeading())#</a></h1>
			<!--- <h1> YOUR PAGE HEADER <small>:: YOUR DATES</small></h1> --->
		</cfoutput>
	</div>
	<cfoutput>
		#view('car/filter')#
	</cfoutput>
	<br clear="both" />
	<cfoutput>
		<form method="post" action="#buildURL('car.availability')#" id="carAvailabilityForm">
			<input type="hidden" name="bSelect" value="1">
			<input type="hidden" name="SearchID" value="#rc.SearchID#">
			<input type="hidden" name="sCategory" id="sCategory" value="">
			<input type="hidden" name="sVendor" id="sVendor" value="">
		</form>

		<!--- If no records can be retrieved from the initial search or change search form. --->
		<div id="noSearchResults" class="hidden noresults">There were no cars found based on your search criteria. <a href="##displaySearchWindow" id="displayModal" data-toggle="modal" data-backdrop="static">CHANGE YOUR SEARCH</a> and try again.</div>

		<!--- If no records can be displayed after filtering. --->
		<div id="noFilteredResults" class="hidden noresults">No cars are available for your filtered criteria.</div>

		<div id="vendorRow" class="carrow">
			<table>
			<tr>
				<td>
					<div style="width:150px;position:relative;float:left;">
						&nbsp;
					</div>
				</td>
				<cfloop collection="#session.searches[rc.SearchID].stCarVendors#" item="sVendor">
					<td>
					<div id="vendor#LCase(sVendor)#" align="center" style="width:120px;border-left:1px solid ##CCC;position:relative;float:left;">
						<cfif ArrayFind(application.Accounts[session.AcctID].aPreferredCar, sVendor)>
							<span class="preferred blue bold">PREFERRED</span><br>
						</cfif>
						<img alt="#sVendor#" src="assets/img/cars/#sVendor#.png" style="padding-bottom:10px;">
					</div>
					</td>
				</cfloop>
			</tr>
			</table>
		</div>

		<br clear="all">

		<div id="categoryRow">
			<cfloop collection="#session.searches[rc.SearchID].stCarCategories#" item="sCategory">
				<cfset stCar = session.searches[rc.SearchID].stCars[sCategory]>

				<cfif NOT StructIsEmpty(stCar)>
					<!--- Grab the user-friendly vehicle class and category for the first item in the structure. --->
					<cfloop collection="#stCar#" item="vendor">
						<cfset vehicleClass=stCar[vendor].vehicleClass & " " & stCar[vendor].category />
						<cfbreak />
					</cfloop>

					<div id="row#LCase(sCategory)#" class="carrow" style="margin-top:5px; margin-bottom:0px;">
						<table>
						<tr>
							<td>
								<div style="width:150px;position:relative;float:left;">
									<cfif ArrayFind(rc.Policy.aCarSizes, sCategory)>
										<span class="preferred blue bold">PREFERRED</span><br>
									</cfif>
									<span class="carType">#vehicleClass#</span><br />
									<img alt="#sCategory#" src="assets/img/cars/#sCategory#.jpg" width="86"><br />
									<!--- Original image tag below.
									<img alt="#sCategory#" src="assets/img/cars/#sCategory#.jpg" style="padding-top:10px;" width="127"><br> --->
								</div>
							</td>

							<cfloop collection="#session.searches[rc.SearchID].stCarVendors#" item="sVendor">
								<td>
									<div id="#LCase(sCategory)##LCase(sVendor)#" align="center" style="width:120px;border-left:1px solid ##CCC;position:relative;float:left;">
										<cfif StructKeyExists(session.searches[rc.SearchID].stCars[sCategory], sVendor)>
											<cfset buttonType="btn-primary" />
											<!--- If out of policy --->
											<cfif NOT session.searches[rc.SearchID].stCars[sCategory][sVendor].Policy>
												<span rel="tooltip" class="outofpolicy" title="#ArrayToList(session.searches[rc.SearchID].stCars[sCategory][sVendor].aPolicies)#">OUT OF POLICY</span><br />
												<cfset buttonType="" />												
											</cfif>
											<cfset stRate = session.searches[rc.SearchID].stCars[sCategory][sVendor]>
											<!--- If best/lowest rate --->
											<cfif stRate.EstimatedTotalAmount EQ session.searches[SearchID].stCars.fLowestCarRate>
												<span class="green">BEST RATE</span>
												<cfset buttonType="btn-success" />
											</cfif>
											<!--- If corporate/contracted rate --->
											<cfif stRate.Corporate>
												CONTRACTED
											</cfif><br />
											<cfif stRate.Currency IS 'USD'>
												<cfset thisRate="$" & Round(stRate.EstimatedTotalAmount) />
											<cfelse>
												<cfset thisRate=stRate.Currency & Round(stRate.EstimatedTotalAmount) />
											</cfif>
											<input type="submit" class="btn #buttonType#" onClick="submitCarAvailability('#sCategory#', '#sVendor#');" value="#thisRate#">
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
		</div>
	</cfoutput>
<cfelse>
	<cfoutput>
		#view('car/error')#
	</cfoutput>
</cfif>