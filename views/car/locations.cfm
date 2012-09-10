<cfoutput>
	#NumberFormat(rc.nTimer)# ms
</cfoutput>
<br clear="both">
<cfoutput>
	<div class="car">
		<table width="300" heigth="100%" padding="4">
		<cfloop collection="#rc.stLocations#" item="sLocation">
			<cfif sLocation NEQ 'Center'>
				<cfset stLocation = rc.stLocations[sLocation]>
				<tr>
					<td>
						#sLocation#
					</td>
					<td>
						#stLocation.Street#
					</td>
				</tr>
			</cfif>
		</cfloop>
		</table>
	</div>
	<div id="map" style="float:right;width:900px;height:500px;"></div>
</cfoutput>
<cfset sPins = ''>
<cfloop collection="#rc.stLocations#" item="sLocation">
	<cfif sLocation NEQ 'Center'>
		<cfset sPins = sPins&"['"&rc.stLocations[sLocation].Street&"',"&rc.stLocations[sLocation].sLatLong&"],">
	</cfif>
</cfloop>
<script src="https://ecn.dev.virtualearth.net/mapcontrol/mapcontrol.ashx?v=7.0&s=1" charset="UTF-8" type="text/javascript"></script>
<script type="text/javascript">
function loadMap(lat, long) {
	var center = new Microsoft.Maps.Location(lat,long);
	var mapOptions = {
		credentials: "AkxLdyqDdWIqkOGtLKxCG-I_Z5xEdOAEaOfy9A9wnzgXtvtPnncYjFQe6pjmpCJA", 
		center: center, 
		mapTypeId: Microsoft.Maps.MapTypeId.road, 
		enableSearchLogo: false, 
		zoom: 12
	}
	map = new Microsoft.Maps.Map(document.getElementById("map"), mapOptions);
	var pins = new Object;
	var stAddresses = <cfoutput>[#spins#]</cfoutput>
	for (loopcnt = 0; loopcnt < stAddresses.length; loopcnt++) {
		var loclat = stAddresses[loopcnt][2];
		var loclong = stAddresses[loopcnt][1];
		var locadd = stAddresses[loopcnt][0];
		pins[loopcnt] = new Microsoft.Maps.Pushpin(new Microsoft.Maps.Location(loclat,loclong), {text:loopcnt, visible:true});
		pins[loopcnt].title = locadd;
		pins[loopcnt].description = locadd;
		map.entities.push(pins[loopcnt]);
	}
	map.entities.push(new Microsoft.Maps.Pushpin(center, {zIndex:-51}));
	return false;
}
<cfoutput>
loadMap(#GetToken(rc.stLocations.Center, 2, ',')#,#GetToken(rc.stLocations.Center, 1, ',')#)
</cfoutput>
</script>