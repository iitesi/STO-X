<cfset qryFutureTrips = application.fw.factory.getBean("TripManager").getFutureTrips(userId=session.userId,accountIds=session.accountIds)/>
<div class="container-fluid" id="Main">
	<div class="row">
		<div class="col-md-10 col-md-offset-1">
			<div class="panel panel-default">
				<div class="panel-heading">
					<h1 class="panel-title">My Trips <cfif qryFutureTrips.recordCount><cfoutput>(#qryFutureTrips.recordCount#)</cfoutput></cfif></h1>
				</div>
				<div class="panel-body" style="padding:15px 25px 25px 25px;">
					<cfif qryFutureTrips.recordCount>
						<cfoutput query="qryFutureTrips" group="TravelerDisplay">
							<cfset name = GetToken(GetToken(TravelerDisplay, 1, ","), 1, "/")/>
							<a href="https://viewtrip.travelport.com/##!/itinerary?loc=#RecLoc#&lName=#name#" target="_blank">
								<div class="badge" style="cursor:pointer;padding:20px 20px 20px 20px;text-align:left;white-space:normal;word-wrap:break-word;">
									<p style="padding:5px 0 5px 0;color:##696969;font-size:13px;font-weight:bold;">
										#dateFormat(DepartDate,"ddd, mmm d yyyy")# - #dateFormat(ReturnDate,"ddd, mmm d yyyy")#
									</p>
									<p style="font-size:13px;padding:0 0 5px 0;">
										#TravelerDisplay#
									</p>
									<cfif Ticketed eq "TICKETED">
										<p style="font-size:11px;padding:0 0 5px 0;">
											<img src="/booking/assets/img/airlines/#trim(VendorCode)#_sm.png"/>
											<b>#replace(ctyrtg,'-',' <span style="margin:0 5px 0 5px;" class="glyphicon glyphicon-arrow-right"></span> ','all')#</b>
										</p>
									<cfelseif Types contains "A" AND Ticketed EQ "NOT TICKETED">
										<p style="font-size:13px;padding:0 0 5px 0;">
											<span class="glyphicon glyphicon-exclamation-sign"></span>
											<b>Not Ticketed</b>
										</p>
									</cfif>
									<p>
										<div style="float:left;">
											<button style="width:55px;margin-right:3px;" class="btn <cfif Types contains 'A'>btn-primary</cfif>">
												Air
											</button>
											<button style="width:55x;margin-right:3px;" class="btn <cfif Types contains 'H'>btn-primary</cfif>">
												Hotel
											</button>
											<button style="width:55px;margin-right:0;" class="btn <cfif Types contains 'C'>btn-primary</cfif>">
												Car
											</button>
										</div>
										<div style="float:right;">
											<button type="submit" class="btn btn-primary">
												<span class="glyphicon glyphicon-new-window"></span>
											</button>
										</div>
									</p>
								</div>
							</a>
						</cfoutput>
					<cfelse>
						<p style="text-align:center;">
							No trips found.
						</p>
					</cfif>
				</div>
			</div>
		</div>
	</div>
</div>