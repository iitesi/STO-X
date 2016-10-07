<cfif (rc.Filter.getAir() AND structKeyExists(session.searches[rc.SearchID].stItinerary, 'Air'))
OR NOT rc.Filter.getAir()>
	<div class="container">
		<div class="page-header">
			<cfoutput>
				<h1>#rc.Filter.getCarHeading()#</h1>
				<h2><a href="##displaySearchWindow" id="displayModal" class="change-search" data-toggle="modal" data-backdrop="static"><i class="fa fa-search"></i> Change Search</a></h2>
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

		<!-- Lee's new table -->
		<div class="panel panel-default carResultPanel">
  
		<div class="panel-heading">Results</div>
		<table class="table carResults rwd-table">
			<thead>
					<th class="carTypeCol">&nbsp;</th>
				<cfloop collection="#session.searches[rc.SearchID].stCarVendors#" item="sVendor">
					<th>
					<div id="vendor#LCase(sVendor)#" align="center" style="">
						
						<img alt="#sVendor#" src="assets/img/cars/#sVendor#.png" style="padding-top:28px;">
						<cfif session.searches[rc.SearchID].stCarVendors[sVendor].Location EQ "ShuttleOffAirport">
							<div>Shuttle Off Terminal</div>
						</cfif>
						<cfif ArrayFind(application.Accounts[session.AcctID].aPreferredCar, sVendor)>
							<small class="green">PREFERRED</small>
						</cfif>
					</div>
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
								<td class="carTypeCol" data-th="#vehicleClass#">
									
										
										<span class="carType">#vehicleClass#</span><br />

										<!--- Had to add the style width below for IE. --->
										<img alt="#sCategory#" src="assets/img/cars/#sCategory#.jpg" width="86" style="width:86px;">
										<cfif ArrayFind(rc.Policy.aCarSizes, sCategory)>
											<small class="green">PREFERRED</small>
										</cfif>
									
								</td>

								<cfloop collection="#session.searches[rc.SearchID].stCarVendors#" item="sVendor">
									<td  id="#LCase(sCategory)##LCase(sVendor)#" data-th="#StructKeyExists(application.stCarVendors, sVendor) ? application.stCarVendors[sVendor] : 'No Car Vendor found'# <cfif session.searches[rc.SearchID].stCarVendors[sVendor].Location EQ "ShuttleOffAirport">(Shuttle Off Terminal)</cfif>">
										
										
											<cfif StructKeyExists(session.searches[rc.SearchID].stCars[sCategory], sVendor)>
												<cfset buttonType="btn-primary" />
												<cfset stRate = session.searches[rc.SearchID].stCars[sCategory][sVendor]>
												<!--- If out of policy --->
												<cfif NOT session.searches[rc.SearchID].stCars[sCategory][sVendor].Policy>
													
													<small rel="tooltip" class="outofpolicy" title="#ArrayToList(session.searches[rc.SearchID].stCars[sCategory][sVendor].aPolicies)#">OUT OF POLICY</small><br />
													
													<cfset buttonType="" />
											
													
												</cfif>
												<!--- If best/lowest rate --->
												<cfif stRate.EstimatedTotalAmount EQ session.searches[SearchID].lowestCarRate>
													<cfset buttonType="btn-success" />
												</cfif>
												<!--- If corporate/contracted rate --->
											
												<cfif stRate.Currency IS 'USD'>
													<cfset thisRate="$" & Round(stRate.EstimatedTotalAmount) />
												<cfelse>
													<cfset thisRate=stRate.Currency & Round(stRate.EstimatedTotalAmount) />
												</cfif>
												<input type="submit" class="btn #buttonType#" onClick="submitCarAvailability('#sCategory#', '#sVendor#', '#session.searches[rc.SearchID].stCars[sCategory][sVendor].Location#', '#session.searches[rc.SearchID].stCars[sCategory][sVendor].Location#');" value="#thisRate#">
												<cfif stRate.Corporate
													AND rc.Filter.getAcctID() NEQ 497
													AND rc.Filter.getAcctID() NEQ 499>
													<br /><small class="blue">CONTRACTED</small>
													<!--- CONTRACTED --->
												<cfelseif stRate.Corporate>
													<img src="assets/img/clients/dhlPreferred.png">
													<!--- CONTRACTED --->
												</cfif>
												<cfif stRate.EstimatedTotalAmount EQ session.searches[SearchID].lowestCarRate>
													<br /><small class="green">BEST RATE</small>
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
			
		
		<!-- End Lee's new table -->
		<!--
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
							<span class="ribbon ribbon-r-pref"></span>
						</cfif>
						<img alt="#sVendor#" src="assets/img/cars/#sVendor#.png" style="padding-top:28px;">
						<cfif session.searches[rc.SearchID].stCarVendors[sVendor].Location EQ "ShuttleOffAirport">
							<div>Shuttle Off Terminal</div>
						</cfif>
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
								<div style="width:150px;height:72px;position:relative;float:left;">
									<cfif ArrayFind(rc.Policy.aCarSizes, sCategory)>
										<span class="ribbon ribbon-r-pref-small"></span>
									</cfif>
									<span class="carType">#vehicleClass#</span><br />

									<!--- Had to add the style width below for IE. --->
									<img alt="#sCategory#" src="assets/img/cars/#sCategory#.jpg" width="86" style="width:86px;"><br />
								</div>
							</td>

							<cfloop collection="#session.searches[rc.SearchID].stCarVendors#" item="sVendor">
								<td>
									<div align="center" style="width:120px;height:72px;border-left:1px solid ##CCC;position:relative;float:left;">
									<div id="#LCase(sCategory)##LCase(sVendor)#" align="center">
										<cfif StructKeyExists(session.searches[rc.SearchID].stCars[sCategory], sVendor)>
											<cfset buttonType="btn-primary" />
											<cfset stRate = session.searches[rc.SearchID].stCars[sCategory][sVendor]>
											<!--- If out of policy --->
											<cfif NOT session.searches[rc.SearchID].stCars[sCategory][sVendor].Policy>
												<cfif stRate.EstimatedTotalAmount NEQ session.searches[SearchID].lowestCarRate>
													<br />
												</cfif>
												<span rel="tooltip" class="outofpolicy" title="#ArrayToList(session.searches[rc.SearchID].stCars[sCategory][sVendor].aPolicies)#">OUT OF POLICY</span>
												<cfif stRate.EstimatedTotalAmount EQ session.searches[SearchID].lowestCarRate>
													<br />
												</cfif>
												<cfset buttonType="" />
											<cfelse>
												<br />
											</cfif>
											<!--- If best/lowest rate --->
											<cfif stRate.EstimatedTotalAmount EQ session.searches[SearchID].lowestCarRate>
												<span class="green">BEST RATE</span>
												<cfset buttonType="btn-success" />
											</cfif>
											<!--- If corporate/contracted rate --->
											<cfif stRate.Corporate
												AND rc.Filter.getAcctID() NEQ 497
												AND rc.Filter.getAcctID() NEQ 499>
												<span class="ribbon ribbon-r-cont-small"></span>
												<!--- CONTRACTED --->
											<cfelseif stRate.Corporate>
												<img src="assets/img/clients/dhlPreferred.png">
												<!--- CONTRACTED --->
											</cfif><br />
											<cfif stRate.Currency IS 'USD'>
												<cfset thisRate="$" & Round(stRate.EstimatedTotalAmount) />
											<cfelse>
												<cfset thisRate=stRate.Currency & Round(stRate.EstimatedTotalAmount) />
											</cfif>
											<input type="submit" class="btn #buttonType#" onClick="submitCarAvailability('#sCategory#', '#sVendor#', '#session.searches[rc.SearchID].stCars[sCategory][sVendor].Location#', '#session.searches[rc.SearchID].stCars[sCategory][sVendor].Location#');" value="#thisRate#">
										<cfelse>
											<br />UNAVAILABLE
										</cfif>
									</div>
									</div>
								</td>
							</cfloop>
						</tr>
						</table>
					</div>
				</cfif>
			</cfloop>
		</div>
		-->
	</cfoutput>
<cfelse>
	<cfoutput>
		#view('car/error')#
	</cfoutput>
</cfif>