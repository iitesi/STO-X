<cfcomponent output="false">
	
	<cffunction name="getRooms" access="remote" returntype="any" returnformat="plain" output="false">
		<cfargument name="nSearchID" />
		<cfargument name="nHotelCode" />
		<cfargument name="HotelRateCodes" />
    <cfargument name="stPolicy" default="#application.stPolicies[session.searches[arguments.nSearchID].nPolicyID]#">
		
		<cfset local.stHotel = session.searches[nSearchID].stHotels[nHotelCode] />
		<cfset local.stNewHotel = StructKeyExists(stHotel,'Rooms') ? stHotel['Rooms'] : {} />
		<cfset local.RoomsData = QueryNew("PropertyID,Count,RoomDescription,Rate,CurrencyCode,RoomRateCategory,RoomRatePlanType,Policy", "varchar,numeric,varchar,varchar,varchar,varchar,varchar,boolean")>
		
		<!--- If not a preferred vendor then all are out of policy. Set this one time and compare in the loop for rates --->
		<cfset PreferredVendorPolicy = NOT ArrayFind(stHotel['apolicies'],'Not a preferred vendor') /><!--- Policy = true if it's in policy, which is why NOT is needed --->
		
		<cfset local.count = 0 />
		<cfloop list="#StructKeyList(stNewHotel,'|')#" index="local.sRoom" delimiters="|">
			<cfset Policy = PreferredVendorPolicy AND stNewHotel[sRoom]['HotelRate']['BaseRate'] LT arguments.stPolicy.Policy_HotelMaxRate /> 
			<cfset count++ />
			<cfset Row = QueryAddRow(RoomsData)>
			<cfset QuerySetCell(RoomsData,'PropertyID',nHotelCode,Row)>
			<cfset QuerySetCell(RoomsData,'Count',count,Row)>
			<cfset QuerySetCell(RoomsData,'RoomDescription',sRoom,Row)>
			<cfset QuerySetCell(RoomsData,'Rate',stNewHotel[sRoom]['HotelRate']['BaseRate'],Row)>
			<cfset QuerySetCell(RoomsData,'CurrencyCode',stNewHotel[sRoom]['HotelRate']['CurrencyCode'],Row)>
			<cfset QuerySetCell(RoomsData,'RoomRateCategory',stNewHotel[sRoom]['RoomRateCategory'],Row)>
			<cfset QuerySetCell(RoomsData,'RoomRatePlanType',stNewHotel[sRoom]['RoomRatePlanType'],Row)>
			<cfset QuerySetCell(RoomsData,'Policy',Policy,Row)>
		</cfloop>

		<cfset rates = RoomsData><!--- serializeJSON() when using jQuery --->
		
		<cfreturn rates />

	</cffunction>
	
</cfcomponent>