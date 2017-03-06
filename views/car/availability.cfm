<cfif (rc.Filter.getAir() AND structKeyExists(session.searches[rc.SearchID].stItinerary, 'Air'))
OR NOT rc.Filter.getAir()>
	<div class="container">
		<div class="page-header">
			<cfoutput>
				<h1>#rc.Filter.getCarHeading()#</h1>
				<h2><a  id="displayModal" class="change-search" data-toggle="modal"  data-target="##displaySearchWindow"><i class="fa fa-search"></i> Change Search</a></h2>
			</cfoutput>
		</div>
	</div>

	<!--- SOLA/LSU --->
	<cfif ( rc.acctID EQ 254
		OR rc.acctID EQ 255 )
		AND (( rc.Filter.getCarDropoffAirport() NEQ ''
			AND structKeyExists( application.stAirports, rc.Filter.getCarDropoffAirport() )
			AND application.stAirports[ rc.Filter.getCarDropoffAirport() ].stateCode EQ 'LA' )
		OR  ( rc.Filter.getCarPickupAirport() NEQ ''
			AND structKeyExists( application.stAirports, rc.Filter.getCarPickupAirport() )
			AND application.stAirports[ rc.Filter.getCarPickupAirport() ].stateCode EQ 'LA' ))>
		<div class="alert alert-info">Enterprise mandated for all in-state vehicle rentals.</div>
	</cfif>
	<cfif ( rc.acctID EQ 469 )>
		<div class="alert alert-info"><b>IMPORTANT:</b> If requesting an <b>Enterprise car delivery</b> prior to 9:00am local time, please contact the Enterprise location with your confirmation number and request a <b>"Quick Start"</b> delivery, the Enterprise location will deliver the car to the Grange location the evening prior and leave the keys with Security.</div>
	</cfif>

	<div>
		<cfoutput>
			#view('car/search')#
			#view('car/filter')#
		</cfoutput>
	</div>
	<cfoutput>
		<form method="post" action="#buildURL('car.availability')#" id="carAvailabilityForm">
			<input type="hidden" name="bSelect" value="1">
			<input type="hidden" name="SearchID" value="#rc.SearchID#">
			<input type="hidden" name="sCategory" id="sCategory" value="">
			<input type="hidden" name="sVendor" id="sVendor" value="">
			<input type="hidden" name="pickUpLocationKey" value="#rc.pickUpLocationKey#">
			<input type="hidden" name="dropOffLocationKey" value="#rc.dropOffLocationKey#">
			<input type="hidden" name="pickUpLocationType" id="pickUpLocationType" value="">
			<input type="hidden" name="dropOffLocationType" id="dropOffLocationType" value="">
		</form>

		<!--- If no records can be retrieved from the initial search or change search form. --->
		<div id="noSearchResults" class="hidden noresults">There were no cars found based on your search criteria. <a href="##displaySearchWindow" id="displayModal" data-toggle="modal" data-backdrop="static">CHANGE YOUR SEARCH</a> and try again.</div>

		<!--- If no records can be displayed after filtering. --->
		<div id="noFilteredResults" class="hidden noresults">No cars are available for your filtered criteria.</div>


			<div class="grid-view panel panel-default carResultPanel hidden">
				<table class="table carResults rwd-table">
				<thead>
						<th class="carTypeCol">&nbsp;</th>
					<cfloop collection="#session.searches[rc.SearchID].stCarVendors#" item="sVendor">
						<th id="vendor#LCase(sVendor)#">


							<img alt="#sVendor#" src="assets/img/cars/#sVendor#.png" style="padding-top:28px;">
							<cfif session.searches[rc.SearchID].stCarVendors[sVendor].Location EQ "ShuttleOffAirport">
								<div>Shuttle Off Terminal</div>
							</cfif>
							<cfif ArrayFind(application.Accounts[session.AcctID].aPreferredCar, sVendor)>
								<br /><small class="green">PREFERRED</small>
							</cfif>

						</th>
					</cfloop>
				</thead>
				<tbody>
					<cfloop collection="#session.searches[rc.SearchID].stCarCategories#" item="sCategory">
						<cfset stCar = session.searches[rc.SearchID].stCars[sCategory]>

						<cfif NOT StructIsEmpty(stCar)>
							<!--- Grab the user-friendly vehicle class and category for the first item in the structure. --->
							<cfloop collection="#stCar#" item="vendor">
								<cfset vehicleClass=stCar[vendor].vehicleClass & " " & stCar[vendor].category />
								<cfbreak />
							</cfloop>

								<tr id="row#LCase(sCategory)#">
									<td class="carTypeCol hiddenOnList" data-th="#vehicleClass#">


											<span class="carType">#vehicleClass#</span><br />

											<!--- Had to add the style width below for IE. --->
											<img alt="#sCategory#" src="assets/img/cars/#sCategory#.jpg" width="86" style="width:86px;">
											<cfif ArrayFind(rc.Policy.aCarSizes, sCategory)>
												<br /><small class="green">PREFERRED</small>
											</cfif>

									</td>

									<cfloop collection="#session.searches[rc.SearchID].stCarVendors#" item="sVendor">
										<td <cfif ArrayFind(application.Accounts[session.AcctID].aPreferredCar, sVendor)>class="preferredVendor"</cfif>  id="#LCase(sCategory)##LCase(sVendor)#" data-th="#StructKeyExists(application.stCarVendors, sVendor) ? application.stCarVendors[sVendor] : 'No Car Vendor found'#<cfif session.searches[rc.SearchID].stCarVendors[sVendor].Location EQ "ShuttleOffAirport">(Shuttle Off Terminal)</cfif>">


												<cfif StructKeyExists(session.searches[rc.SearchID].stCars[sCategory], sVendor)>
													<cfset buttonType="btn-primary" />
													<cfset stRate = session.searches[rc.SearchID].stCars[sCategory][sVendor]>
													<!--- If out of policy --->
													<cfif NOT session.searches[rc.SearchID].stCars[sCategory][sVendor].Policy>
														<cfset buttonType="" />
													</cfif>
													<!--- If best/lowest rate --->
													<cfif stRate.EstimatedTotalAmount EQ session.searches[SearchID].lowestCarRate>
														<cfset buttonType="btn-success" />
													</cfif>
													<!--- If corporate/contracted rate --->
													<div class="hiddenOnGrid car-vehicle-class">#vehicleClass#
														<cfif stRate.Corporate
															AND rc.Filter.getAcctID() NEQ 497
															AND rc.Filter.getAcctID() NEQ 499>
															<br /><small class="blue">CONTRACTED</small>
														</cfif>
													</div>

													<cfif stRate.Currency IS 'USD'>
														<cfset thisRate="$" & Round(stRate.EstimatedTotalAmount) />
													<cfelse>
														<cfset thisRate=stRate.Currency & Round(stRate.EstimatedTotalAmount) />
													</cfif>
													<input type="submit" class="btn #buttonType#" onClick="submitCarAvailability('#sCategory#', '#sVendor#', '#session.searches[rc.SearchID].stCars[sCategory][sVendor].Location#', '#session.searches[rc.SearchID].stCars[sCategory][sVendor].Location#');" value="#thisRate#">
													<cfif stRate.Corporate
														AND rc.Filter.getAcctID() NEQ 497
														AND rc.Filter.getAcctID() NEQ 499>
														<br /><small class="blue hiddenOnList">CONTRACTED</small>
														<!--- CONTRACTED --->
													<cfelseif stRate.Corporate>
														<img src="assets/img/clients/dhlPreferred.png">
														<!--- CONTRACTED --->
													</cfif>
													<cfif stRate.EstimatedTotalAmount EQ session.searches[SearchID].lowestCarRate>
														<br /><small class="green">BEST RATE</small>
													</cfif>
													<cfif NOT session.searches[rc.SearchID].stCars[sCategory][sVendor].Policy>
														<br /><small rel="tooltip" class="outofpolicy" title="#ArrayToList(session.searches[rc.SearchID].stCars[sCategory][sVendor].aPolicies)#">OUT OF POLICY</small>
													</cfif>
												<cfelse>
													<br />UNAVAILABLE
												</cfif>


										</td>
									</cfloop>
								</tr>


						</cfif>
					</cfloop>
				</tbody>
			</table>
			</div>


	</cfoutput>
<cfelse>
	<cfoutput>
		#view('car/error')#
	</cfoutput>
</cfif>
