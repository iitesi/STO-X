<cfcomponent output="false">
	
	<cffunction name="getRooms" access="remote" returntype="any" returnformat="plain" output="false">
	
		<cfargument name="nSearchID" />
		<cfargument name="nHotelCode" />
		<cfargument name="HotelRateCodes" required="false" type="string">	
		
		<cfset local.stNewHotel = StructKeyExists(session.searches[nSearchID].stHotels[nHotelCode],'Rooms') ? session.searches[nSearchID].stHotels[nHotelCode]['Rooms'] : {} />
		<cfset local.NegotiatedRateCode = session.searches[nSearchID].stHotels[nHotelCode]['NegotiatedRateCode'] />
		<cfset local.RoomsData = QueryNew("Count, RoomDescription, Rate, CurrencyCode, NegotiatedRateCode", "numeric, varchar, varchar, varchar, varchar")>
		
		<cfset local.count = 0 />
		<cfloop list="#StructKeyList(stNewHotel,'|')#" index="local.sRoom" delimiters="|">
			<cfset count++ />
			<cfset Row = QueryAddRow(RoomsData)>
			<cfset temp = QuerySetCell(RoomsData, 'Count', count, Row)>
			<cfset temp = QuerySetCell(RoomsData, 'RoomDescription', sRoom, Row)>
			<cfset temp = QuerySetCell(RoomsData, 'Rate', stNewHotel[sRoom]['HotelRate']['BaseRate'], Row)>
			<cfset temp = QuerySetCell(RoomsData, 'CurrencyCode', stNewHotel[sRoom]['HotelRate']['BaseRate'] , Row)>
			<cfset temp = QuerySetCell(RoomsData, 'NegotiatedRateCode', NegotiatedRateCode, Row)>
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

/* {
	"COLUMNS":[
		"RATE_ID","RATE_CODE","RATE_DESC","AVERAGE_RATE","TOTAL_COST","RATE_HIC","CURRENCY","RATEORDER","RATE_ORDER","ROOM_POLICY","POLICY"
	],
	"DATA":[
		[28,"ADTADPR","ADV PURCHASE ADA DDBL TUBTUB WITH RAILS: 2 DOUBLE GRAND BEDS: FLOORS<br>",197,197,"","USD",4,4,0,"0"],
		[27,"AKSADPR","ADV PURCHASE ADA KING SHOWERROLL IN SHOWER: 1 KING GRAND BED: FLOORS<br>",197,197,"","USD",4,4,0,"0"],
		[26,"AKTADPR","ADV PURCHASE ADA KING TUBTUB WITH RAILS: 1 KING GRAND BED: FLOORS<br>",197,197,"","USD",4,4,0,"0"]
	]
} */		

<!--- <cfset local.RoomsData = '{"COLUMNS":["BaseRate","CurrencyCode","RoomDescription","NegotiatedRateCode","Count"],"DATA":[' />
<cfset count = 0 />
<cfloop list="#StructKeyList(stNewHotel,'|')#" index="local.sRoom" delimiters="|">
	<cfset count++ />
	<cfset RoomsData&='["#stNewHotel[sRoom]['HotelRate']['BaseRate']#","#stNewHotel[sRoom]['HotelRate']['CurrencyCode']#","#sRoom#","#NegotiatedRateCode#","#NumberFormat(count,'000')#"]' />
	
	<cfif count NEQ ListLen(StructKeyList(stNewHotel,'|'),'|')>
		<cfset RoomsData&=',' />
	</cfif>
</cfloop>
<cfset RoomsData&=']}' />

<cfset rates = serializeJSON(RoomsData)>

<cfset rates = Replace(rates,'\','','ALL') />
<cfreturn rates />  --->