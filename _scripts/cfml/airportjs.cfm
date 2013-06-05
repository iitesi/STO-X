<!--- domestic only --->
<cfquery name="getAllAirports" datasource="book">
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
<cffile action="write" file="c:/inetpub/wwwroot/stosearch/localdata/autosuggest.js" nameconflict="overwrite" output="#airports#">

<!--- international & domestic --->
<cfquery name="getAllAirports" datasource="book">
	SELECT Location_Display
	FROM lu_Geography
	WHERE Location_Type = 125
</cfquery>
<cfprocessingdirective suppresswhitespace="yes">
	<cfsavecontent variable="intlairports">
	<cfoutput>var airports = [<cfset Count = 0><cfloop query="getAllAirports"><cfset Count = Count + 1>"#Location_Display#"<cfif CurrentRow NEQ RecordCount>,</cfif> </cfloop>];</cfoutput>
	</cfsavecontent>
</cfprocessingdirective>
<cffile action="write" file="c:/inetpub/wwwroot/stosearch/localdata/autosuggestintl.js" nameconflict="overwrite" output="#intlairports#">