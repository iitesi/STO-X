<cfcomponent output="false" accessors="true">

	<cfproperty name="AirPrice">
	<cfproperty name="car">
	<cfproperty name="HotelPrice">

<!---
init
--->
	<cffunction name="init" output="false">
		<cfargument name="AirPrice">
		<cfargument name="car">
		<cfargument name="HotelPrice">

		<cfset setAirPrice(arguments.AirPrice)>
		<cfset setCar(arguments.car)>
		<cfset setHotelPrice(arguments.HotelPrice)>

		<cfreturn this>
	</cffunction>

<!---
doCouldYou
--->
	<cffunction name="doCouldYou" output="false">
		<cfargument name="Filter"   required="true">
		<cfargument name="Account">
		<cfargument name="Policy">

		<cfset local.OriginDate = arguments.Filter.getDepartDate()>
		<cfset calendarStartDate = dateAdd('d', -7, arguments.Filter.getDepartDate())>
		<cfset local.CDNumbers = (structKeyExists(arguments.Policy.CDNumbers, arguments.Filter.getValueID()) ? arguments.Policy.CDNumbers[arguments.Filter.getValueID()] : (structKeyExists(arguments.Policy.CDNumbers, 0) ? arguments.Policy.CDNumbers[0] : []))>
		<cfset threadnames = {}>
		<cfset local.CouldYou = structKeyExists(session.searches[SearchID],'CouldYou') ? session.searches[SearchID].CouldYou : {}>
		<cfset local.Air = arguments.Filter.getAir()>
		<cfset local.Car = arguments.Filter.getCar()>
		<cfset local.Hotel = arguments.Filter.getHotel()>

		<cfloop from="1" to="2" index="MonthOption">
			<cfset calendarDate = MonthOption EQ 2 ? DateAdd('m',1,calendarStartDate) : calendarStartDate>
			<cfset Start = false>
			<cfset Done = false>
			<cfloop from="1" to="8" index="week">
				<cfloop from="1" to="7" index="day">
					<cfif DayOfWeek(CreateDate(Year(calendarDate), Month(calendarDate), 1)) EQ day AND NOT Start>
						<cfset Start = true>
						<cfset viewDay = 0>
					</cfif>
					<cfif Start AND viewDay LT DaysInMonth(calendarDate)>
						<cfset viewDay++>
					</cfif>
					<cfset tdName = ''>
					<cfif Start AND abs(datediff('d',DateFormat(CreateDate(Year(calendarDate), Month(calendarDate), viewDay),'m/d/yyyy'),DateFormat(OriginDate,'m/d/yyyy'))) LTE 7 AND abs(datediff('d',DateFormat(CreateDate(Year(calendarDate), Month(calendarDate), viewDay),'m/d/yyyy'),DateFormat(OriginDate,'m/d/yyyy'))) NEQ 0>
						<cfset tdName = ' id="Air#DateFormat(CreateDate(Year(calendarDate), Month(calendarDate), viewDay),'yyyymmdd')#"'>
					</cfif>
					<cfif Start AND viewDay LTE DaysInMonth(calendarDate) AND NOT Done>
						<cfset DateDifference = DateDiff('d',DateFormat(OriginDate,'m/d/yyyy'),DateFormat(CreateDate(Year(calendarDate), Month(calendarDate),viewDay),'m/d/yyyy'))>
						<cfset local.FullDate = CreateODBCDate(Year(calendarDate)&'-'&Month(calendarDate)&'-'&viewDay)>
						<cfset viewDate = DateFormat(FullDate,"yyyymmdd")>
						<cfif Len(Trim(tdName))>

							<!--- Was CouldYou already done? --->
							<cfset CouldYouDone = false>
							<cfif Air>
								<cfset CouldYouDone = structKeyExists(CouldYou,'Air') AND structKeyExists(CouldYou.Air,FullDate) ? true : false>	
							</cfif>
							<cfif Car AND NOT CouldYouDone>
								<cfset CouldYouDone = structKeyExists(CouldYou,'Car') AND structKeyExists(CouldYou.Car,FullDate) ? true : false>	
							</cfif>
							<cfif Hotel AND NOT CouldYouDone>
								<cfset CouldYouDone = structKeyExists(CouldYou,'Hotel') AND structKeyExists(CouldYou.Hotel,FullDate) ? true : false>	
							</cfif>							

							<cfset CouldYouDone = false>
							<cfif NOT CouldYouDone>
								
								<cfset threadnames['could#DateDifference#'] = ''>
								<cfthread name="could#DateDifference#" Filter="#arguments.Filter#" SearchID="#arguments.SearchID#" DateDifference="#DateDifference#" Account="#Account#" 
									Policy="#Policy#" CDNumbers="#CDNumbers#" OriginDate="#OriginDate#">

									<cfset arguments.OriginDate = OriginDate>

									<cfset thread.AirTotal = 0>
									<cfset thread.CarTotal = 0>
									<cfset thread.HotelTotal = 0>
									<cfset thread.CouldYouDate = DateAdd('d',DateDifference,arguments.OriginDate)>

									<!---Air--->
									<cfif Air>
										<cfset local.stSelected = structNew('linked')>
										<cfloop collection="#session.searches[arguments.SearchID].stItinerary.Air.Groups#" item="local.stGroup" index="local.nGroup">
											<cfset stSelected[nGroup].Groups[0] = stGroup>
										</cfloop>
										<cfset sMessage 	= AirPrice.prepareSoapHeader(stSelected, session.searches[url.SearchID].stItinerary.Air.Class, session.searches[url.SearchID].stItinerary.Air.Ref, DateDifference)>
										<cfset sResponse 	= AirPrice.getUAPI().callUAPI('AirService', sMessage, arguments.SearchID)>
										<cfset aResponse 	= AirPrice.getUAPI().formatUAPIRsp(sResponse)>
										<cfset stTrips		= AirPrice.getAirParse().parseTrips(aResponse, {})>
										<cfset nTripKey		= AirPrice.getTripKey(stTrips)>
										<cfif NOT StructIsEmpty(stTrips)>
											<cfset thread.AirTotal = stTrips[nTripKey].Total>
										</cfif>
									</cfif>

									<!---Car--->
									<cfif Car>
										<cfset local.sCarType 		= session.searches[arguments.SearchID].stItinerary.Car.VehicleClass&session.searches[arguments.SearchID].stItinerary.Car.Category>
										<cfset local.sCarChain 		= session.searches[arguments.SearchID].stItinerary.Car.VendorCode>
										<cfif NOT structIsEmpty(CDNumbers)>
											<cfset local.sMessage		= car.prepareSoapHeader(arguments.Filter, arguments.Account, arguments.Policy, DateDifference, CDNumbers)>
											<cfset local.sResponse 	= car.getUAPI().callUAPI('VehicleService', sMessage, SearchID)>
											<cfset local.aResponse 	= car.getUAPI().formatUAPIRsp(sResponse)>
											<cfset local.stCars     = car.parseCars(aResponse, 1)>
											<cfif structKeyExists(stCars, sCarType) AND structKeyExists(stCars[sCarType], sCarChain)>
												<cfset thread.CarTotal = Mid(stCars[sCarType][sCarChain].EstimatedTotalAmount,4)>
											</cfif>
										</cfif>
										<cfif thread.CarTotal EQ 0>
											<cfset local.sMessage		= car.prepareSoapHeader(arguments.Filter, arguments.Account, arguments.Policy, DateDifference)>
											<cfset local.sResponse 	= car.getUAPI().callUAPI('VehicleService', sMessage, SearchID)>
											<cfset local.aResponse 	= car.getUAPI().formatUAPIRsp(sResponse)>
											<cfset local.stCars     = car.parseCars(aResponse, 0)>
											<cfif structKeyExists(stCars, sCarType) AND structKeyExists(stCars[sCarType], sCarChain)>
												<cfset thread.CarTotal = Mid(stCars[sCarType][sCarChain].EstimatedTotalAmount,4)>
											</cfif>
										</cfif>
									</cfif>

									<!--- Hotel --->
									<cfif Hotel>

										<cfset local.sMessage 	= HotelPrice.prepareSoapHeader(session.searches[url.SearchID].stItinerary.Hotel.HotelChain, session.searches[url.SearchID].stItinerary.Hotel.HotelID, DateDifference, arguments.Filter)>
										<cfset local.sResponse 	= HotelPrice.getUAPI().callUAPI('HotelService', sMessage, arguments.SearchID, session.searches[url.SearchID].stItinerary.Hotel.HotelID, DateDifference)>
										<cfset local.stResponse = HotelPrice.getUAPI().formatUAPIRsp(sResponse)>
										<cfset local.stHotels 	= HotelPrice.parseHotelRooms(stResponse, session.searches[url.SearchID].stItinerary.Hotel.HotelID, arguments.SearchID)>
										<cfset local.stRates 		= structKeyExists(stHotels,'Rooms') ? stHotels['Rooms'] : 'Sold Out'>
										<cfif isStruct(stRates)>
											<cfset local.RoomDescriptions = structKeyList(stRates,'|')>
											<cfset local.LowRate = 10000>
											<cfloop list="#RoomDescriptions#" index="local.HotelDesc" delimiters="|">
												<cfif structKeyExists(stRates[HotelDesc].HotelRate,'BaseRate')>
													<cfset local.LowRate = min(stRates[HotelDesc]['HotelRate']['BaseRate'],LowRate)>
												</cfif>
											</cfloop>
										<cfelse>
											<cfset local.LowRate = 'Sold Out'>
										</cfif>
										<cfset thread.HotelTotal = LowRate>

									</cfif>

								</cfthread>

							</cfif>

						</cfif>
					</cfif>
					<cfset Done = Start AND viewDay EQ DaysInMonth(calendarDate) ? true : false>
				</cfloop>
				<cfif Done>
					<cfbreak>
				</cfif>
			</cfloop>
		</cfloop>

		<cfthread action="join" name="#StructKeyList(threadnames)#">
		<cfset local.stCouldYouResults = {}>
		<cfloop list="#structKeyList(threadnames)#" index="local.CouldYou">
			<cfset local.stCouldYou = cfthread[CouldYou]>
			<cfset local.CouldYouDate = createODBCDate(stCouldYou.CouldYouDate)>
			<cfset local.stCouldYouResults.Air[CouldYouDate] = stCouldYou.AirTotal EQ 0 ? 'Flight Does not Operate' : stCouldYou.AirTotal>
			<cfset local.stCouldYouResults.Car[CouldYouDate] = stCouldYou.CarTotal EQ 0 ? 'Car Not Available' : stCouldYou.CarTotal>
			<cfset local.stCouldYouResults.Hotel[CouldYouDate] = stCouldYou.HotelTotal EQ 0 ? 'Hotel Not Available' : stCouldYou.HotelTotal>
		</cfloop>
		<cfset session.searches[SearchID].CouldYou = stCouldYouResults>
		<cfdump var="#stCouldYouResults#" abort>
		<!--- <cfdump var="#stCouldYouResults#">
		<cfdump var="#session.searches[SearchID].CouldYou#" abort> --->

<!---


		<cfabort>
		<cfset local.stTrip = ''>
		<cfset local.nTotalPrice = 0>
		<cfset local.Search 			= getSearch(arguments.SearchID)>
		<cfset local.CouldYouDate = CreateODBCDate(DateAdd('d',arguments.nTripDay,Search.Depart_DateTime))>

		<cfif NOT structKeyExists(session.searches[SearchID].CouldYou,'Air') OR NOT structKeyExists(session.searches[SearchID].CouldYou.Air,CouldYouDate)>
			<cfset nTripKey = AirPrice.doAirPrice(arguments.SearchID,arguments.sCabin,arguments.bRefundable,arguments.nTrip,arguments.nTripDay)>

			<cfloop array="#nTripKey#" index="local.Element">
				<cfif Element.xmlName EQ 'air:AirPriceResult'>
					<cfset local.stTrip = Element.XMLChildren.1.XMLAttributes>
					<cfset local.nTotalPrice = Mid(stTrip.TotalPrice, 4)>
				</cfif>
			</cfloop>

			<cfset session.searches[SearchID].CouldYou.Air[CouldYouDate] = nTotalPrice EQ 0 ? 'Flight Does not Operate' : nTotalPrice>
			<cfelse>
			<cfset nTotalPrice = session.searches[SearchID].CouldYou.Air[CouldYouDate]>
		</cfif>

		<cfset nTotalPrice = doTotalPrice(arguments.SearchID,arguments.nTripDay,arguments.nTotal)>--->

		<cfreturn >
	</cffunction>

<!---
doTotalPrice
--->
	<cffunction name="doTotalPrice" output="false">
		<cfargument name="SearchID">
		<cfargument name="nTripDay"		default="0">
		<cfargument name="nTotal">

		<cfset local.SearchID 		= arguments.SearchID>
		<cfset local.Search 			= getSearch(SearchID)>
		<cfset local.CouldYouDate = CreateODBCDate(DateAdd('d',nTripDay,Search.Depart_DateTime))>
		<cfset local.Air 				= session['Searches'][SearchID]['Air']>
		<cfset local.Car 				= session['Searches'][SearchID]['Car']>
		<cfset local.Hotel				= session['Searches'][SearchID]['Hotel']>
		<cfset local.count 				= 0>
		<cfset local.nTotalPrice 	= 0>
		<cfset local.stTotalPrice = {}>

		<cfset local.aTypes = []>
		<cfset Air ? arrayAppend(aTypes,'Air') : ''>
		<cfset Car ? arrayAppend(aTypes,'Car') : ''>
		<cfset Hotel ? arrayAppend(aTypes,'Hotel') : ''>
		<cfset local.nTypes = arrayLen(aTypes)>

		<cfloop array="#aTypes#" index="local.Type">
			<cfif structKeyExists(session.searches[SearchID].CouldYou,Type) AND structKeyExists(session.searches[SearchID].CouldYou[Type],CouldYouDate)>
				<cfif isNumeric(nTotalPrice)>
					<cfif isNumeric(session.searches[SearchID].CouldYou[Type][CouldYouDate])>
						<cfset nTotalPrice+=session.searches[SearchID].CouldYou[Type][CouldYouDate]>
					<cfelse>
						<cfset nTotalPrice = session.searches[SearchID].CouldYou[Type][CouldYouDate]>
					</cfif>
				<cfelse>
					<cfif NOT isNumeric(session.searches[SearchID].CouldYou[Type][CouldYouDate])>
						<cfset nTotalPrice&= session.searches[SearchID].CouldYou[Type][CouldYouDate]>
					</cfif>
				</cfif>
				<cfset local.count++>
			</cfif>
		</cfloop>
		<!--- Min Weekday fare - 99CC99 --->
		<cfif nTypes EQ count>
			<cfset local.stTotalPrice.nTotalPrice = nTotalPrice>
			<cfif isNumeric(nTotalPrice)>
				<cfif nTotalPrice GTE nTotal>
					<cfset local.stTotalPrice.sDifference = 'Higher/Same'>
					<cfset local.stTotalPrice.sColor = 'FFCCCC'>
				<cfelse>
					<cfset local.stTotalPrice.sDifference = 'Lower'>
					<cfset local.stTotalPrice.sColor = 'A3C8ED'>
				</cfif>
			<cfelse>
				<cfset local.stTotalPrice.sDifference = 'Not available'>
				<cfset local.stTotalPrice.sColor = 'CCCCCC'>
			</cfif>
		</cfif>
		<cfset local.stTotalPrice.Day = DateFormat(CouldYouDate,'d')>

		<cfreturn stTotalPrice>
	</cffunction>

<!--- getsearch --->
	<cffunction name="getsearch" output="false">
		<cfargument name="SearchID">

		<cfquery name="local.getsearch" datasource="book" cachedwithin="#createTimeSpan(1,0,0,0)#">
		SELECT Depart_DateTime
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.SearchID#" cfsqltype="cf_sql_numeric">
		</cfquery>

		<cfreturn getsearch>
	</cffunction>

</cfcomponent>