<cfcomponent output="false">
	
	<cffunction name="getRooms" access="remote" returntype="any" returnformat="plain" output="false">
		<cfargument name="searchID" type="numeric" required="true" />
		<cfargument name="propertyID" type="numeric" required="true" />
		<cfargument name="Policy" type="numeric" required="false" default="#application.Policies[session.PolicyID]#">


		<cfset local.hotel = session.searches[arguments.SearchID].hotels[NumberFormat(PropertyID,'00000')] />
		<cfset local.newHotel = StructKeyExists(hotel,'Rooms') ? hotel['Rooms'] : {} />
		<!--- <cfset local.CorporateRateCodes = application.Accounts[session.AcctID]['Hotel_RateCodes'] /> --->
		<cfset local.RoomsData					= QueryNew("PropertyID,Count,RoomDescription,Rate,CurrencyCode,RoomRateCategory,RoomRatePlanType,Policy,GovernmentRate",
																			"varchar,numeric,varchar,varchar,varchar,varchar,varchar,boolean,boolean")>
		
		<!--- If not a preferred vendor then all are out of policy. Set this one time and compare in the loop for rates --->
		<cfset local.PreferredVendorPolicy = NOT ArrayFind(hotel['apolicies'],'Not a preferred vendor') /><!--- Policy = true if it's in policy, which is why NOT is needed --->
		
		<cfset local.count = 0 />
		<cfloop list="#StructKeyList(newHotel,'|')#" index="local.sRoom" delimiters="|">
			<cfset local.Policy = PreferredVendorPolicy AND newHotel[sRoom]['HotelRate']['BaseRate'] LT arguments.stPolicy.Policy_HotelMaxRate /> 
			<cfset local.count++ />
			<cfset local.Row = QueryAddRow(RoomsData)>
			<cfset QuerySetCell(RoomsData,'PropertyID',PropertyID,Row)>
			<cfset QuerySetCell(RoomsData,'Count',count,Row)>
			<cfset QuerySetCell(RoomsData,'RoomDescription',sRoom,Row)>
			<cfset QuerySetCell(RoomsData,'Rate',newHotel[sRoom]['HotelRate']['BaseRate'],Row)>
			<cfset QuerySetCell(RoomsData,'CurrencyCode',newHotel[sRoom]['HotelRate']['CurrencyCode'],Row)>
			<cfset QuerySetCell(RoomsData,'RoomRateCategory',newHotel[sRoom]['RoomRateCategory'],Row)>
			<cfset QuerySetCell(RoomsData,'RoomRatePlanType',newHotel[sRoom]['RoomRatePlanType'],Row)>
			<cfset QuerySetCell(RoomsData,'Policy',Policy,Row)>
			<cfset QuerySetCell(RoomsData,'GovernmentRate',newHotel[sRoom]['GovernmentRate'],Row)>
		</cfloop>

		<cfquery name="local.RoomsData" dbtype="query">
		SELECT PropertyID, Count, RoomDescription, Rate, CurrencyCode, RoomRateCategory, RoomRatePlanType, Policy, GovernmentRate
		FROM local.RoomsData
		ORDER BY Rate
		</cfquery>
		
		<cfset local.rates = serializeJSON(RoomsData)>
		
		<cfreturn rates />

	</cffunction>
	
	<cffunction name="getAmenities" access="remote" returntype="any" returnformat="plain" output="false">
		<cfargument name="SearchID" />
		<cfargument name="PropertyID" />
		
		<cfset local.hotel = session.searches[arguments.SearchID].hotels[PropertyID]['Amenities'] />
		<cfset local.stAmenities = [] />
		<cfloop list="#structKeyList(hotel)#" index="local.Amenity">
			<cfset arrayAppend(local.stAmenities,application.stAmenities[Amenity]) />
		</cfloop>
		<cfset arraySort(local.stAmenities,'text') />

		<cfset local.stAmenities = serializeJSON(local.stAmenities)>
		
		<cfreturn local.stAmenities />

	</cffunction>
	
</cfcomponent>