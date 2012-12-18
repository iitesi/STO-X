<cfsetting showdebugoutput="false" />
<style type="text/css">
#details-tabs {
	background-color:rgba(0,0,0,0.3);
}
#details-tabs li {
	cursor:pointer;
	font-size:12px;
	font-weight:bold;
}
#details-tabs li {
	color:#92A9B8;
	text-align: center;
	position:relative;
	float:left;
	border:1px solid #CBC7BD;
	border-radius:3px 3px 0 0;
	height:20px;
	line-height: 15px;
	width: 135px;
	overflow:hidden;
	padding:10px 10px;
	margin: 0 5px 0 5px;
	position:relative;
	top:1px;
	background-color: #F4F0F0;
	font-family:"Merriweather",Georgia,Times,serif,Times,serif;
}
#details-tabs .selected {
	color:#666666;
	border-bottom:4px solid #FFFFFF;
	z-index: 500;
	background-color: #FFFFFF;
}
#tabcontent {
	min-width: 700px;
	min-height: 150px;
	padding: 25px;
	border: 4px solid #CBC7BD;  
	margin-top: -4px;
	z-index: 0;
	font-family:"Merriweather",Georgia,Times,serif,Times,serif;
}
#seatcontent {
	font-family:"Merriweather",Georgia,Times,serif,Times,serif;
	font-size: 11px;
}
ul.tabs {
	margin:7px;
	padding:0px;
}
ul.tabs li {
	list-style:none;
	display:inline;
}
ul.tabs li a {
	background-color:#F4F0F0;
	color:#0090D2;
	padding:8px 14px 8px 14px;
	text-decoration:none;
	font-weight:bold;
	text-transform:uppercase;
	border:1px solid #CBC7BD;
}
ul.tabs li a:hover {
	color:#0090D2;
	border-color:#2f343a;
	cursor: hand;
}  
ul.tabs li a.active {
	color:#0090D2;
	background-color: #FFFFFF;
	border:1px solid #0090D2;
}
</style>
<cfoutput>
	<div>
		<ul id="details-tabs">
			<cfset sURL = 'Search_ID=#rc.nSearchID#&PropertyID=#url.PropertyID#&RoomRatePlanType=#url.RoomRatePlanType#&HotelChain=#url.HotelChain#'>
			<cfset TabTypes = 'Details,Rooms,Amenities,Photos' />
			<cfloop list="#TabTypes#" index="OneTab">
				<a onClick="$('##tabcontent').html('One moment please.');$('##overlayContent').load('?action=hotel.popup&sDetails=#OneTab#&#sURL#')">
					<li <cfif rc.sDetails EQ OneTab>class="selected"</cfif>>
						#OneTab#
					</li>
				</a>				
			</cfloop>
		</ul>
		<br clear="all">
		<div id="tabcontent">
			#view('hotel/#rc.sDetails#')#
		</div>
	</div>
</cfoutput>