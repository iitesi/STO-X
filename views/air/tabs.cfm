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
	height:90px;
	margin-top:-85px;
	border-bottom:1px solid #CAC9C9;
}
#header .logo {
	position:relative;
	float:left;
	padding:0 50px 0 20px;
	z-index:1000;
}
#results-tabs {
	line-height:70px;
	margin-top:20px;
}
#results-tabs li {
	cursor:pointer;
	font-size:12px;
	font-weight:bold;
	line-height:30px;
	margin-top:37px;
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
	<ul id="results-tabs">
		<cfloop array="#StructKeyArray(session.searches)#" index="nSearchID">
			<li id="tab-1" class="tab selected" style="max-width: 251px; margin-right: 0.5%; width: 42.4286%;">
				<div class="tab-border">
					<div class="flex-wrapper">
						<div class="flex-option">
							<span class="flex-content">
								<span class="vmiddle"><a href="index.cfm?Search_ID=#rc.Search_ID#&action=air.lowfare">#session.searches[rc.Search_ID].Heading#</a></span>
							</span>
						</div>
					</div>
				</div>
			</li>
		</cfloop>
	</ul>
	<ul id="results-tabs">
		<li id="tab-1" class="tab selected" style="max-width: 170px; margin-right: 0.5%; width: 42.4286%;">
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
	<ul id="results-tabs">
		<li id="tab-1" class="tab selected" style="max-width: 150px; margin-right: 0.5%; width: 42.4286%;">
			<div class="tab-border">
				<div class="flex-wrapper">
					<div class="flex-option">
						<span class="flex-content">
							<span class="vmiddle">Search Hotels</span>
						</span>
					</div>
				</div>
			</div>
		</li>
	</ul>
	<ul id="results-tabs">
		<li id="tab-1" class="tab selected" style="max-width: 140px; margin-right: 0.5%; width: 42.4286%;">
			<div class="tab-border">
				<div class="flex-wrapper">
					<div class="flex-option">
						<span class="flex-content">
							<span class="vmiddle">Search Cars</span>
						</span>
					</div>
				</div>
			</div>
		</li>
	</ul>
</cfoutput>