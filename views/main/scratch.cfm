<cfset es = application.fw.factory.getBean('EnvironmentService') />
<cfset lm = application.fw.factory.getBean('LocationManager') />
<!---
<cfoutput>
	#es.getGoogleMapsAPIKey()#
	<br>
	#binaryDecode( es.getGoogleMapsAPIKey(), "Base64" )#
</cfoutput>

<cfabort>--->
<cfoutput>#lm.geoCodeAddress( '1309 Castalia Dr', "Cary", "NC")#</cfoutput>