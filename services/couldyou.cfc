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
		<cfargument name="Filter" required="true">
		<cfargument name="Account">
		<cfargument name="Policy">

		<cfset local.OriginDate = arguments.Filter.getDepartDate()>
		<cfset local.calendarStartDate = dateAdd('d', -7, arguments.Filter.getDepartDate())>
		<cfset local.CDNumbers = (structKeyExists(arguments.Policy.CDNumbers, arguments.Filter.getValueID()) ? arguments.Policy.CDNumbers[arguments.Filter.getValueID()] : (structKeyExists(arguments.Policy.CDNumbers, 0) ? arguments.Policy.CDNumbers[0] : []))>
		<cfset local.threadnames = {}>
		<cfset local.CouldYou = structKeyExists(session.searches[SearchID],'CouldYou') ? session.searches[SearchID].CouldYou : {}>
		<cfset local.viewDay = 0>

		<cfset local.Air = arguments.Filter.getAir() />
		<cfset local.Car = arguments.Filter.getCar() />
		<cfset local.Hotel = arguments.Filter.getHotel() />

		<!--- get Current Total --->
		<cfset local.stItinerary = session.searches[url.SearchID].stItinerary />
		<cfset local.SelectedTotal = 0 />
		<cfif Air>
			<cfset local.SelectedTotal+= stItinerary.Air.Total />
		</cfif>
		<cfif Car>
			<cfset local.SelectedTotal+= Mid(stItinerary.Car.EstimatedTotalAmount,4) />
		</cfif>
		<cfif Hotel>
			<cfset local.SelectedTotal+= stItinerary.Hotel.TotalRate />
		</cfif>

		<cfloop from="1" to="2" index="MonthOption">
			<cfset local.calendarDate = MonthOption EQ 2 ? DateAdd('m',1,calendarStartDate) : calendarStartDate>
			<cfset local.Start = false>
			<cfset local.Done = false>
			<cfloop from="1" to="8" index="week">
				<cfloop from="1" to="7" index="day">
					<cfif DayOfWeek(CreateDate(Year(calendarDate), Month(calendarDate), 1)) EQ day AND NOT Start>
						<cfset local.Start = true>
						<cfset local.viewDay = 0>
					</cfif>
					<cfif Start AND viewDay LT DaysInMonth(calendarDate)>
						<cfset local.viewDay++>
					</cfif>
					<cfset local.tdName = ''>
					<cfif Start>
						<cfset local.absoluteDateValue = abs(datediff('d',DateFormat(CreateDate(Year(calendarDate), Month(calendarDate), viewDay),'m/d/yyyy'),DateFormat(OriginDate,'m/d/yyyy'))) />
						<cfif absoluteDateValue LTE 7 AND absoluteDateValue NEQ 0>
							<cfset local.tdName = ' id="Air#DateFormat(CreateDate(Year(calendarDate), Month(calendarDate), viewDay),'yyyymmdd')#"'>
						</cfif>
					</cfif>
					<cfif Start AND viewDay LTE DaysInMonth(calendarDate) AND NOT Done>
						<cfset local.DateDifference = DateDiff('d',DateFormat(OriginDate,'m/d/yyyy'),DateFormat(CreateDate(Year(calendarDate), Month(calendarDate),viewDay),'m/d/yyyy'))>
						<cfset local.FullDate = CreateODBCDate(Year(calendarDate)&'-'&Month(calendarDate)&'-'&viewDay)>
						<cfset local.viewDate = DateFormat(FullDate,"yyyymmdd")>
						<cfif Len(Trim(tdName))>

							<!--- Was CouldYou already done? --->
							<cfset local.CouldYouDone = false>
							<cfif Air>
								<cfset local.CouldYouDone = structKeyExists(CouldYou,'Air') AND structKeyExists(CouldYou.Air,FullDate) ? true : false>	
							</cfif>
							<cfif Car AND NOT CouldYouDone>
								<cfset local.CouldYouDone = structKeyExists(CouldYou,'Car') AND structKeyExists(CouldYou.Car,FullDate) ? true : false>	
							</cfif>
							<cfif Hotel AND NOT CouldYouDone>
								<cfset local.CouldYouDone = structKeyExists(CouldYou,'Hotel') AND structKeyExists(CouldYou.Hotel,FullDate) ? true : false>	
							</cfif>

							<!--- <cfdump var="#CouldYou#">
							<cfdump var="#CouldYouDone#" abort> --->
							<!--- <cfset local.CouldYouDone = false> --->
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
									<cfif arguments.Filter.getAir()>
										<cfset local.stSelected = structNew('linked')>
										<cfloop collection="#session.searches[arguments.SearchID].stItinerary.Air.Groups#" item="local.stGroup" index="local.nGroup">
											<cfset local.stSelected[nGroup].Groups[0] = stGroup>
										</cfloop>
										<cfset local.sMessage 	= AirPrice.prepareSoapHeader(stSelected, session.searches[url.SearchID].stItinerary.Air.Class, session.searches[url.SearchID].stItinerary.Air.Ref, DateDifference)>
										<cfset local.sResponse 	= AirPrice.getUAPI().callUAPI('AirService', sMessage, arguments.SearchID)>
										<cfset local.aResponse 	= AirPrice.getUAPI().formatUAPIRsp(sResponse)>
										<cfset local.stTrips		= AirPrice.getAirParse().parseTrips(aResponse, {})>
										<cfset local.nTripKey		= AirPrice.getTripKey(stTrips)>
										<cfif NOT StructIsEmpty(stTrips)>
											<cfset thread.AirTotal = stTrips[nTripKey].Total />
										</cfif>
									</cfif>

									<!---Car--->
									<cfif arguments.Filter.getCar()>
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
												<cfset thread.CarTotal = Mid(stCars[sCarType][sCarChain].EstimatedTotalAmount,4) />
											</cfif>
										</cfif>
									</cfif>

									<!--- Hotel --->
									<cfif arguments.Filter.getHotel()>
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
					<cfset local.Done = Start AND viewDay EQ DaysInMonth(calendarDate) ? true : false>
				</cfloop>
				<cfif Done>
					<cfbreak>
				</cfif>
			</cfloop>
		</cfloop>

		<cfthread action="join" name="#StructKeyList(threadnames)#">
		<!--- <cfdump var="#cfthread#" abort> --->
		<cfif NOT structIsEmpty(threadnames)>
			<cfset local.stCouldYouResults = {}>
			<cfset local.stCouldYouResults.CurrentTotal = SelectedTotal />
			<cfloop list="#structKeyList(threadnames)#" index="local.CouldYou">
				<cfset local.stCouldYou = cfthread[CouldYou]>
				<cfset local.CouldYouDate = createODBCDate(stCouldYou.CouldYouDate)>
				<cfset local.stCouldYouResults.Air[CouldYouDate] = stCouldYou.AirTotal EQ 0 ? 'Flight Does not Operate' : stCouldYou.AirTotal /><!--- Set flight price to string if 0 --->
				<cfset local.stCouldYouResults.Car[CouldYouDate] = stCouldYou.CarTotal EQ 0 ? 'Car not available' : stCouldYou.CarTotal />
				<cfset local.stCouldYouResults.Hotel[CouldYouDate] = stCouldYou.HotelTotal EQ 0 ? 'Hotel not available' : stCouldYou.HotelTotal />
				<cfset local.stCouldYouResults.TotalPrice[CouldYouDate] = doTotalPrice(FullDate,stCouldYouResults.Air[CouldYouDate],stCouldYouResults.Car[CouldYouDate],stCouldYouResults.Hotel[CouldYouDate],SelectedTotal,arguments.Filter) />
			</cfloop>
			<cfset session.searches[SearchID].CouldYou = stCouldYouResults>
		<cfelse>
			<cfset local.stCouldYouResults = session.searches[SearchID].CouldYou />
		</cfif>
		<!--- CouldYouResults <cfdump var="#stCouldYouResults#" abort> --->
		<!--- <cfdump var="#session.searches[SearchID].CouldYou#" abort> --->

		<cfreturn >
	</cffunction>



<!---
doTotalPrice
--->
	<cffunction name="doTotalPrice" output="false">
		<cfargument name="CouldYouDate">
		<cfargument name="AirTotal">
		<cfargument name="CarTotal">
		<cfargument name="HotelTotal">
		<cfargument name="SelectedTotal">
		<cfargument name="Filter">

		<cfset local.CouldYouDate = arguments.CouldYouDate />
		<cfset local.Air 					= arguments.Filter.getAir()>
		<cfset local.Car 					= arguments.Filter.getCar()>
		<cfset local.Hotel				= arguments.Filter.getHotel()>
		<cfset local.count 				= 0>
		<cfset local.nTotalPrice 	= 0>
		<cfset local.stTotalPrice = {}>

		<cfset local.aTypes = []>
		<cfset Air ? arrayAppend(aTypes,'Air') : ''>
		<cfset Car ? arrayAppend(aTypes,'Car') : ''>
		<cfset Hotel ? arrayAppend(aTypes,'Hotel') : ''>
		<cfset local.nTypes = arrayLen(aTypes)>

		<cfloop array="#aTypes#" index="local.Type">
			<cfset local.CurrentType = arguments[Type&'Total'] />
			<cfif isNumeric(nTotalPrice)>
				<cfif isNumeric(CurrentType)>
					<cfset nTotalPrice+=CurrentType>
				<cfelse>
					<cfset nTotalPrice = CurrentType>
				</cfif>
			<cfelse>
				<cfif NOT isNumeric(CurrentType)>
					<cfset nTotalPrice&=CurrentType>
				</cfif>
			</cfif>
			<cfset local.count++>
		</cfloop>
		<!--- Min Weekday fare - 99CC99 --->
		<cfif nTypes EQ count>
			<cfset local.stTotalPrice.nTotalPrice = nTotalPrice>
			<cfif isNumeric(nTotalPrice)>
				<cfif nTotalPrice GTE arguments.SelectedTotal>
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

		<cfreturn stTotalPrice>
	</cffunction>

</cfcomponent>