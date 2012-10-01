<cfcomponent output="false">
	
<!--- getPhotos --->
	<cffunction name="getPhotos" access="public" output="false" returntype="array">
		<cfargument name="stHotels">
		
		<cfset local.PropertyIDs = [] />
		<cfloop array="#arguments.stHotels#" index="sHotel">
			<cfset ArrayAppend(PropertyIDs,sHotel)>
		</cfloop>
		<cfset PropertyIDs = arrayToList(PropertyIDs,"','") />

		<cfquery name="local.getPhotos" datasource="Book">
		SELECT Property_ID, Signature_Image
		FROM lu_hotels
		WHERE PROPERTY_ID in ('#PreserveSingleQuotes(PropertyIDs)#')
		</cfquery>

		<cfset local.stPhotos = {} />
		<cfloop query="getPhotos">
			<cfset stPhotos[NumberFormat(getPhotos.Property_ID,'00000')] = getPhotos.Signature_Image />
		</cfloop>

		<cfreturn stPhotos />
	</cffunction>
		
</cfcomponent>