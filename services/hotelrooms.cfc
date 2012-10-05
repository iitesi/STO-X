<cfcomponent output="false">
	
	<cffunction name="getRooms" access="remote" returntype="any" returnformat="plain" output="false">
		<cfargument name="nSearchID" />
		<cfargument name="nHotelCode" />
		<cfargument name="HotelRateCodes" />
		<cfargument name="stPolicy" default="#application.stPolicies[session.Acct_ID]#" />
		
		<cfset local.stHotel = session.searches[nSearchID].stHotels[nHotelCode] />
		<cfset local.stNewHotel = StructKeyExists(stHotel,'Rooms') ? stHotel['Rooms'] : {} />
		<cfset local.NegotiatedRateCode = session.searches[nSearchID].stHotels[nHotelCode]['NegotiatedRateCode'] />
		<cfset local.RoomsData = QueryNew("PropertyID,Count,RoomDescription,Rate,CurrencyCode,NegotiatedRateCode,Policy", "varchar,numeric,varchar,varchar,varchar,varchar,boolean")>
		
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
			<cfset QuerySetCell(RoomsData,'NegotiatedRateCode',NegotiatedRateCode,Row)>
			<cfset QuerySetCell(RoomsData,'Policy',Policy,Row)>
		</cfloop>

		<cfset rates = serializeJSON(RoomsData)>
		
		<cfreturn rates />

	</cffunction>
	
</cfcomponent>


<!--- <cfset count = 0 />
<cfloop list="#StructKeyList(stNewHotel,'|')#" index="local.sRoom" delimiters="|">
	<cfset count++ />
	<cfset RoomsData[NumberFormat(count,'000')]['Rate']  = stNewHotel[sRoom]['HotelRate']['BaseRate'] />
	<cfset RoomsData[NumberFormat(count,'000')]['CurrencyCode']  = stNewHotel[sRoom]['HotelRate']['CurrencyCode'] />			
	<cfset RoomsData[NumberFormat(count,'000')]['RoomDescription']  = sRoom />
	<cfset RoomsData[NumberFormat(count,'000')]['NegotiatedRateCode']  = NegotiatedRateCode />
</cfloop> --->

<!--- <cfset local.RoomsData = '{"COLUMNS":["BaseRate","CurrencyCode","RoomDescription","NegotiatedRateCode","Count"],"DATA":[' />
<cfset count = 0 />
<cfloop list="#StructKeyList(stNewHotel,'|')#" index="local.sRoom" delimiters="|">
	<cfset count++ />
	<cfset RoomsData&='["#stNewHotel[sRoom]['HotelRate']['BaseRate']#","#stNewHotel[sRoom]['HotelRate']['CurrencyCode']#","#sRoom#","#NegotiatedRateCode#","#NumberFormat(count,'000')#"]' />
	
	<cfif count NEQ ListLen(StructKeyList(stNewHotel,'|'),'|')>
		<cfset RoomsData&=',' />
	</cfif>
</cfloop>
<cfset RoomsData&=']}' />--->