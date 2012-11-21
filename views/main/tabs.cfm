<style type="text/css">
#header {
}
#header .logo {
	padding:5px 0 10px 20px;
	clear:right;
}
#results-tabs {
	background-color:rgba(0,0,0,0.3);
}
#results-tabs li {
	cursor:pointer;
	font-size:12px;
	font-weight:bold;
}
#results-tabs li.tab {
	color:#92A9B8;
	position:relative;
	float:left;
	border:1px solid #CAC9C9;
	border-radius:3px 3px 0 0;
	height:40px;
	width: 135px;
	overflow:hidden;
	padding:10px 10px;
	margin: 0 5px 0 5px;
	position:relative;
	top:1px;
	z-index:1001;
	background-color:rgba(255,255,255,0.5);
	border-bottom:1px solid #CAC9C9;
}
#results-tabs li.tab img {
	position:relative;
	float:left;
	padding:0 10px 0 0;
}
#results-tabs li.tab.selected {
	color:#666666;
	background-color:rgba(255,255,255,0.8);
	border-bottom:1px solid white;
}
</style>
<cfoutput>
	<img class="logo" src="https://www.shortstravel.com/TravelPortalV2/Images/Clients/STO-Logo.gif">
	<!--- Any air tabs? --->
	<cfset bAir = 0>
	<cfloop array="#StructKeyArray(session.searches)#" index="nSearchID">
		<cfif session.searches[nSearchID].Air>
			<cfset bAir = 1>
			<cfbreak>
		</cfif>
	</cfloop>
	<cfif bAir>
		<cfloop array="#StructKeyArray(session.searches)#" index="nSearchID">
			<cfif session.searches[nSearchID].Air>
				<ul id="results-tabs">
					<li class="tab <cfif rc.action CONTAINS 'air.'>selected</cfif>" style="margin-right: 0.5%">
						<!--- <a href="#buildURL('air.lowfare?Search_ID=#nSearchID#')#">#session.searches[nSearchID].Heading#</a> --->
						<a href="#buildURL('air.lowfare?Search_ID=#nSearchID#')#">
							<h3>Las Vegas</h3>
							Monday, 12-6 to 12-7
						</a>
						<a style="float:right;" href="#buildURL('setup.close?Search_ID=#nSearchID#')#">x</a>
					</li>
				</ul>
			</cfif>
		</cfloop>
		<ul id="results-tabs">
			<li class="tab" style="margin-right: 0.5%">
				<a href="#buildURL('hotel?Search_ID=#rc.Search_ID#')#">
					<img src="assets/img/air.png">
					<h3>New Air Search</h3>
				</a>
			</li>
		</ul>
	</cfif>
	<ul id="results-tabs">
		<li class="tab" style="margin-right: 0.5%">
			<a href="#buildURL('hotel?Search_ID=#rc.Search_ID#')#">
				<img src="assets/img/hotel.png">
				<h3>Hotels in <br>Las Vegas</h3>
			</a>
		</li>
	</ul>
	<ul id="results-tabs">
		<li class="tab" style="margin-right: 0.5%">
			<a href="#buildURL('car.availability?Search_ID=#rc.Search_ID#')#">
				<img src="assets/img/car.png">
				<h3>Cars in <br>Las Vegas</h3>
			</a>
		</li>
	</ul>
</cfoutput>