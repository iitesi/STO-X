<cfif (rc.Filter.getAir() AND structKeyExists(session.searches[rc.SearchID].stItinerary, 'Air'))
OR NOT rc.Filter.getAir()>
	<div class="page-header">
		<cfoutput>
			<h1><a href="#buildURL('car.availability&SearchID=#rc.SearchID#')#">#rc.Filter.getCarHeading()#</a></h1>
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
		<!--- #view('car/filter')# --->
		<div class="carrow">
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
							<span class="medium blue bold">PREFERRED</span><br>
						</cfif>
						<img alt="#sVendor#" src="assets/img/cars/#sVendor#.png" style="padding-bottom:10px;">
					</div>
					</td>
				</cfloop>
			</tr>
			</table>
		</div>

<!--- <cfdump var="#session.searches[rc.SearchID].stCars#" abort> --->
		<br clear="all">

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
									<span class="medium blue bold">PREFERRED</span><br>
								</cfif>
								#vehicleClass#<br />
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
										<cfset stRate = session.searches[rc.SearchID].stCars[sCategory][sVendor]>
										<cfset thisCarRate=Mid(stRate.EstimatedTotalAmount, 4) />
										<cfif thisCarRate EQ session.searches[SearchID].stCars.fLowestCarRate>
											<span class="green">BEST RATE</span>
											<cfset buttonType="btn-success" />
										</cfif>
										<cfif stRate.Corporate>
											CORPORATE
										</cfif><br />
										<input type="submit" class="btn #buttonType# btn-mini" onClick="submitCarAvailability('#sCategory#', '#sVendor#');" value="#(Left(stRate.EstimatedTotalAmount, 3) EQ 'USD' ? '$'&NumberFormat(Mid(stRate.EstimatedTotalAmount, 4)) : stRate.EstimatedTotalAmount)#">
										<!--- Original button below.
										<input type="submit" class="button#stRate.Policy#policy" onClick="submitCarAvailability('#sCategory#', '#sVendor#');" value="#(Left(stRate.EstimatedTotalAmount, 3) EQ 'USD' ? '$'&NumberFormat(Mid(stRate.EstimatedTotalAmount, 4)) : stRate.EstimatedTotalAmount)#"> --->
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
<cfelse>
	<cfoutput>
		#view('car/error')#
	</cfoutput>
</cfif>