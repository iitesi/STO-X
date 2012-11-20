<style type="text/css">
ol, ul {
	list-style: none outside none;
}
.clear {
	clear:both;
}
#header {
	width: 100%;
	position:fixed;
	z-index:999;
	background-color:#FFF;
	margin-top:-85px;
	border-bottom:1px solid #CAC9C9;
}
#header .logo {
	padding:5px 0 10px 20px;
	z-index:1000;
	clear:right;
}
#results-tabs {
	line-height:70px;
}
#results-tabs li {
	cursor:pointer;
	font-size:12px;
	font-weight:bold;
	line-height:30px;
}
#results-tabs li.tab {
	color:#92A9B8;
	position:relative;
	float:left;
}
#results-tabs li.tab.selected {
	color:#666666;
}
#results-tabs li.tab.selected .tab-border {
	background-color:white;
	background-image:none;
	border-bottom:1px solid white;
}
#results-tabs li.tab .tab-border {
	background-position:0 -584px;
	background-repeat:repeat-x;
	border:1px solid #CAC9C9;
	border-radius:3px 3px 0 0;
	height:30px;
	line-height:30px;
	overflow:hidden;
	padding:0 31px;
	position:relative;
	top:1px;
	z-index:1001;
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
					<li id="tab-1" class="tab <cfif rc.action CONTAINS 'air.'>selected</cfif>" style="margin-right: 0.5%">
						<div class="tab-border">
							<div class="flex-wrapper">
								<div class="flex-option">
									<span class="flex-content">
										<span class="vmiddle">
											<a href="#buildURL('air.lowfare?Search_ID=#nSearchID#')#">#session.searches[nSearchID].Heading#</a>
											<a style="float:right;" href="#buildURL('setup.close?Search_ID=#nSearchID#')#">x</a>
										</span>
									</span>
								</div>
							</div>
						</div>
					</li>
				</ul>
			</cfif>
		</cfloop>
		<ul id="results-tabs">
			<li id="tab-1" class="tab  style="margin-right: 0.5%">
				<div class="tab-border">
					<div class="flex-wrapper">
						<div class="flex-option">
							<span class="flex-content">
								<span class="vmiddle">New Air Search</span>
							</span>
						</div>
					</div>
				</div>
			</li>
		</ul>
	</cfif>
	<ul id="results-tabs">
		<li id="tab-1" class="tab  style="margin-right: 0.5%">
			<div class="tab-border">
				<div class="flex-wrapper">
					<div class="flex-option">
						<span class="flex-content">
							<span class="vmiddle">
								<cfif NOT bAir
								OR (StructKeyExists(session.searches[rc.Search_ID], 'Air_Selected')
								AND session.searches[rc.Search_ID].Air_Selected)>
									<a href="#buildURL('hotel?Search_ID=#rc.Search_ID#')#">Hotel</a>
								<cfelse>
									<!--- Show this tab as disabled.  Let them select air first. --->
									Hotel
								</cfif>
							</span>
						</span>
					</div>
				</div>
			</div>
		</li>
	</ul>
	<ul id="results-tabs">
		<li id="tab-1" class="tab" style="margin-right: 0.5%">
			<div class="tab-border">
				<div class="flex-wrapper">
					<div class="flex-option">
						<span class="flex-content">
							<span class="vmiddle">
								<cfif NOT bAir
								OR (StructKeyExists(session.searches[rc.Search_ID], 'Air_Selected')
								AND session.searches[rc.Search_ID].Air_Selected)>
									<a href="#buildURL('car.availability?Search_ID=#rc.Search_ID#')#">Car</a>
								<cfelse>
									<!--- Show this tab as disabled.  Let them select air first. --->
									<cfif session.User_ID NEQ 3605>
										Car
									<cfelse>
										<a href="#buildURL('car.availability?Search_ID=#rc.Search_ID#')#">Car</a>
									</cfif>
								</cfif>
							</span>
						</span>
					</div>
				</div>
			</div>
		</li>
	</ul>
</cfoutput>