<!--- domestic only --->
<!--- <cfquery name="getAllAirports" datasource="booking">
	SELECT Location_Display
	FROM lu_Geography
	WHERE Location_Type = 125
		AND Country_Code IN ('US','VI')
</cfquery>
<cfprocessingdirective suppresswhitespace="yes">
	<cfsavecontent variable="airports">
	<cfoutput>var airports = [<cfset Count = 0><cfloop query="getAllAirports"><cfset Count = Count + 1>"#Location_Display#"<cfif CurrentRow NEQ RecordCount>,</cfif> </cfloop>];</cfoutput>
	</cfsavecontent>
</cfprocessingdirective>
<cffile action="write" file="c:/inetpub/wwwroot/stosearch/localdata/autosuggest.js" nameconflict="overwrite" output="#airports#"> --->

<!--- for the search/assets/localdata/airports-us.js file, we need both international and domestic airports, but no commercial ones. --->
<!--- international & domestic --->
<cfquery name="getAllAirports" datasource="booking">
	SELECT Location_Code, Location_Display
	FROM lu_Geography
	WHERE Location_Type = 125
</cfquery>
<!--- need to put the query results in the following format: {"id":"ABR","text":"Aberdeen Arpt (ABR), Aberdeen, SD, US"} --->
<cfprocessingdirective suppresswhitespace="yes">
	<cfsavecontent variable="intlairports">
	<cfoutput>airports = [<cfloop query="getAllAirports">{"id":"#Location_Code#","text":"#Location_Display#"}<cfif CurrentRow NEQ RecordCount>,</cfif></cfloop>];</cfoutput>
	</cfsavecontent>
</cfprocessingdirective>
<cffile action="write"
	file="c:/inetpub/wwwroot/railo/search/assets/localdata/airports-us2.js"
	nameconflict="overwrite"
	charset="UTF-8"
	output="#intlairports#"/>