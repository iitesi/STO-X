<cfquery name="getAllAirports" datasource="booking">
	SELECT Location_Code
		, Location_Display
	FROM lu_Geography
	WHERE Location_Type = 125
		AND Location_Code NOT IN (	SELECT AirportCode
									FROM RAPT
									WHERE AirportType IN (4,5,6,7,8,9) )
											<!---	4 = Heliport, no club, scheduled service, 
													5 = Bus station, 
													6 = Train station, 
													7 = Unknown - not explained in Travelports documentation
													8 = Heliport, not scheduled, 
													9 = Secondary, not scheduled 
											--->
	ORDER BY Location_Code
</cfquery>

<!--- need to put the query results in the following format: {"id":"ABR","text":"Aberdeen Arpt (ABR), Aberdeen, SD, US"} --->
<cfprocessingdirective suppresswhitespace="yes">
	<cfsavecontent variable="airports">
	<cfoutput>airports = [<cfloop query="getAllAirports">{"id":"#Location_Code#","text":"#Location_Display#"}<cfif CurrentRow NEQ RecordCount>,</cfif></cfloop>];</cfoutput>
	</cfsavecontent>
</cfprocessingdirective>

<cffile action="write"
	file="c:/inetpub/wwwroot/railo/search/assets/localdata/airports-us.js"
	nameconflict="overwrite"
	charset="UTF-8"
	output="#airports#"/>