<cfif (rc.Filter.getAir() AND structKeyExists(session.searches[rc.SearchID].stItinerary, 'Air'))
OR NOT rc.Filter.getAir()>
	<div class="container">
		<div class="page-header">
			<cfoutput>
				<h1>#rc.Filter.getCarHeading()#</h1>
				<h2><a href="##displaySearchWindow" id="displayModal" class="change-search" data-toggle="modal" data-backdrop="static"><i class="icon-search"></i> Change Search</a></h2>
			</cfoutput>
		</div>
	</div>
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
							<span class="ribbon ribbon-r-pref"></span>
						</cfif>
						<img alt="#sVendor#" src="assets/img/cars/#sVendor#.png" style="padding-top:28px;">
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
										<span class="ribbon ribbon-r-pref"></span>
									</cfif>
									<span class="carType">#vehicleClass#</span><br />

									<!--- Had to add the style width below for IE. --->
									<img alt="#sCategory#" src="assets/img/cars/#sCategory#.jpg" width="86" style="width:86px;"><br />
								</div>
							</td>

							<cfloop collection="#session.searches[rc.SearchID].stCarVendors#" item="sVendor">
								<td>
									<div id="#LCase(sCategory)##LCase(sVendor)#" align="center" style="width:120px;height:72px;border-left:1px solid ##CCC;position:relative;float:left;">
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
											<cfif stRate.Corporate>
												<span class="ribbon ribbon-r-cont"></span>
												<!--- CONTRACTED --->
											</cfif><br />
											<cfif stRate.Currency IS 'USD'>
												<cfset thisRate="$" & Round(stRate.EstimatedTotalAmount) />
											<cfelse>
												<cfset thisRate=stRate.Currency & Round(stRate.EstimatedTotalAmount) />
											</cfif>
											<input type="submit" class="btn #buttonType#" onClick="submitCarAvailability('#sCategory#', '#sVendor#');" value="#thisRate#">
										<cfelse>
											<br />UNAVAILABLE
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