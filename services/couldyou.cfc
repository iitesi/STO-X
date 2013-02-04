<cfcomponent output="false" accessors="true">

	<cfproperty name="airprice">
	<cfproperty name="car">

<!---
init
--->
	<cffunction name="init" output="false">
		<cfargument name="airprice">
		<cfargument name="car">

		<cfset setAirPrice(arguments.airprice)>
		<cfset setCar(arguments.car)>

		<cfreturn this>
	</cffunction>

<!---
doCouldYou
--->
	<cffunction name="doCouldYou" output="false">
		<cfargument name="Filter"   required="true" />
		<cfargument name="Account">
		<cfargument name="Policy">

		<cfset local.OriginDate = arguments.Filter.getDepartDate()>
		<cfset calendarStartDate = dateAdd('d', -7, arguments.Filter.getDepartDate()) />
		<cfset local.CDNumbers = (structKeyExists(arguments.Policy.CDNumbers, arguments.Filter.getValueID()) ? arguments.Policy.CDNumbers[arguments.Filter.getValueID()] : (structKeyExists(arguments.Policy.CDNumbers, 0) ? arguments.Policy.CDNumbers[0] : []))>
		<cfset threadnames = {}>
		<cfloop from="1" to="2" index="MonthOption">
			<cfset calendarDate = MonthOption EQ 2 ? DateAdd('m',1,calendarStartDate) : calendarStartDate />
			<cfset Start = false>
			<cfset Done = false><cfloop from="1" to="8" index="week">
				<cfloop from="1" to="7" index="day">
					<cfif DayOfWeek(CreateDate(Year(calendarDate), Month(calendarDate), 1)) EQ day AND NOT Start>
						<cfset Start = true>
						<cfset viewDay = 0>
					</cfif>
					<cfif Start AND viewDay LT DaysInMonth(calendarDate)>
						<cfset viewDay++>
					</cfif>
					<cfset tdName = '' />
					<cfif Start AND abs(datediff('d',DateFormat(CreateDate(Year(calendarDate), Month(calendarDate), viewDay),'m/d/yyyy'),DateFormat(OriginDate,'m/d/yyyy'))) LTE 7 AND abs(datediff('d',DateFormat(CreateDate(Year(calendarDate), Month(calendarDate), viewDay),'m/d/yyyy'),DateFormat(OriginDate,'m/d/yyyy'))) NEQ 0>
						<cfset tdName = ' id="Air#DateFormat(CreateDate(Year(calendarDate), Month(calendarDate), viewDay),'yyyymmdd')#"' />
					</cfif>
					<cfif Start AND viewDay LTE DaysInMonth(calendarDate) AND NOT Done>
						<cfset DateDifference = DateDiff('d',DateFormat(OriginDate,'m/d/yyyy'),DateFormat(CreateDate(Year(calendarDate), Month(calendarDate),viewDay),'m/d/yyyy')) />
						<cfset viewDate = DateFormat(CreateDate(Year(calendarDate), Month(calendarDate), viewDay),"yyyymmdd") />
						<cfif Len(Trim(tdName))>
						<cfset threadnames['could#DateDifference#'] = ''>
						<cfthread
						name="could#DateDifference#"
						Filter="#arguments.Filter#"
						SearchID="#arguments.SearchID#"
						DateDifference="#DateDifference#"
						Account="#Account#"
						Policy="#Policy#"
						CDNumbers="#CDNumbers#">
							<cfset thread.AirTotal = 0>
							<cfset thread.CarTotal = 0>
							<!---Air--->
							<cfif arguments.Filter.getAir()>
								<cfset local.stSelected = structNew('linked')>
								<cfloop collection="#session.searches[arguments.SearchID].stItinerary.Air.Groups#" item="local.stGroup" index="local.nGroup">
									<cfset stSelected[nGroup].Groups[0] = stGroup>
								</cfloop>
								<!--- Put together the SOAP message. --->
								<cfset sMessage 	= airprice.prepareSoapHeader(stSelected, session.searches[url.SearchID].stItinerary.Air.Class, session.searches[url.SearchID].stItinerary.Air.Ref, DateDifference)>
								<cfset thread.sMessage 	= sMessage>
								<!--- Call the UAPI. --->
								<cfset sResponse 	= airprice.getUAPI().callUAPI('AirService', sMessage, arguments.SearchID)>
								<cfset thread.sResponse 	= sResponse>
								<!--- Format the UAPI response. --->
								<cfset aResponse 	= airprice.getUAPI().formatUAPIRsp(sResponse)>
								<!--- Parse the trips. --->
								<cfset stTrips		= airprice.getAirParse().parseTrips(aResponse, {})>
								<cfset nTripKey		= airprice.getTripKey(stTrips)>
								<cfif NOT StructIsEmpty(stTrips)>
									<cfset thread.AirTotal = stTrips[nTripKey].Total>
								</cfif>
							</cfif>
							<!---Car--->
							<cfif arguments.Filter.getCar()>
								<cfset local.sCarType = session.searches[arguments.SearchID].stItinerary.Car.VehicleClass&session.searches[arguments.SearchID].stItinerary.Car.Category>
								<cfset local.sCarChain = session.searches[arguments.SearchID].stItinerary.Car.VendorCode>
								<cfif NOT structIsEmpty(CDNumbers)>
									<cfset local.sMessage	= car.prepareSoapHeader(arguments.Filter, arguments.Account, arguments.Policy, DateDifference, CDNumbers)>
									<cfset local.sResponse 	= car.getUAPI().callUAPI('VehicleService', sMessage, SearchID)>
									<cfset local.aResponse 	= car.getUAPI().formatUAPIRsp(sResponse)>
									<cfset local.stCars     = car.parseCars(aResponse, 1)>
									<cfif structKeyExists(stCars, sCarType)
									AND structKeyExists(stCars[sCarType], sCarChain)>
										<cfset thread.CarTotal = stCars[sCarType][sCarChain].EstimatedTotalAmount>
									</cfif>
								</cfif>
								<cfif thread.CarTotal EQ 0>
									<cfset local.sMessage	= car.prepareSoapHeader(arguments.Filter, arguments.Account, arguments.Policy, DateDifference)>
									<cfset local.sResponse 	= car.getUAPI().callUAPI('VehicleService', sMessage, SearchID)>
									<cfset local.aResponse 	= car.getUAPI().formatUAPIRsp(sResponse)>
									<cfset local.stCars     = car.parseCars(aResponse, 0)>
									<cfif structKeyExists(stCars, sCarType)
									AND structKeyExists(stCars[sCarType], sCarChain)>
										<cfset thread.CarTotal = stCars[sCarType][sCarChain].EstimatedTotalAmount>
									</cfif>
								</cfif>

<!---<cfset thread.CarTotal = car.doAvailability(arguments.Filter, arguments.Account, arguments.Policy, , session.searches[arguments.SearchID].stItinerary.Car.VehicleClass&session.searches[arguments.SearchID].stItinerary.Car.Category, DateDifference)>--->
							</cfif>
						</cfthread>


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
		<!--- <cfdump var="#cfthread#"> --->
		<!--- <cfabort> --->


<!---


		<cfabort>
		<cfset local.stTrip = '' />
		<cfset local.nTotalPrice = 0 />
		<cfset local.Search 			= getSearch(arguments.SearchID) />
		<cfset local.CouldYouDate = CreateODBCDate(DateAdd('d',arguments.nTripDay,Search.Depart_DateTime)) />

		<cfif NOT structKeyExists(session.searches[SearchID].CouldYou,'Air') OR NOT structKeyExists(session.searches[SearchID].CouldYou.Air,CouldYouDate)>
			<cfset nTripKey = airprice.doAirPrice(arguments.SearchID,arguments.sCabin,arguments.bRefundable,arguments.nTrip,arguments.nTripDay) />

			<cfloop array="#nTripKey#" index="local.Element">
				<cfif Element.xmlName EQ 'air:AirPriceResult'>
					<cfset local.stTrip = Element.XMLChildren.1.XMLAttributes />
					<cfset local.nTotalPrice = Mid(stTrip.TotalPrice, 4)>
				</cfif>
			</cfloop>

			<cfset session.searches[SearchID].CouldYou.Air[CouldYouDate] = nTotalPrice EQ 0 ? 'Flight Does not Operate' : nTotalPrice />
			<cfelse>
			<cfset nTotalPrice = session.searches[SearchID].CouldYou.Air[CouldYouDate] />
		</cfif>

		<cfset nTotalPrice = doTotalPrice(arguments.SearchID,arguments.nTripDay,arguments.nTotal) />--->

		<cfreturn >
	</cffunction>

<!---
doAirPriceCouldYou
--->
	<cffunction name="doAirPriceCouldYou" output="false" access="remote" returnformat="json">
		<cfargument name="SearchID" 		required="true" />
		<cfargument name="sCabin" 			required="false"	default="Y" /><!--- Options (one item) - Economy, Y, Business, C, First, F --->
		<cfargument name="bRefundable"	required="false"	default="0" /><!--- Options (one item) - 0, 1 --->
		<cfargument name="nTrip"				required="false"	default="" />
		<cfargument name="nTripDay"			required="false"	default="0" />
		<cfargument name="StartDate"		required="false"	default="" />
		<cfargument name="nTotal" />
		<cfargument name="stAccount" 		required="false"	default="#application.Accounts[session.AcctID]#" />

		<cfset local.stTrip = '' />
		<cfset local.nTotalPrice = 0 />
		<cfset local.Search 			= getSearch(arguments.SearchID) />
		<cfset local.CouldYouDate = CreateODBCDate(DateAdd('d',arguments.nTripDay,Search.Depart_DateTime)) />

		<cfif NOT structKeyExists(session.searches[SearchID].CouldYou,'Air') OR NOT structKeyExists(session.searches[SearchID].CouldYou.Air,CouldYouDate)>
			<cfset nTripKey = airprice.doAirPrice(arguments.SearchID,arguments.sCabin,arguments.bRefundable,arguments.nTrip,arguments.nTripDay) />

			<cfloop array="#nTripKey#" index="local.Element">
				<cfif Element.xmlName EQ 'air:AirPriceResult'>
					<cfset local.stTrip = Element.XMLChildren.1.XMLAttributes />
				  <cfset local.nTotalPrice = Mid(stTrip.TotalPrice, 4)>
				</cfif>
			</cfloop>

			<cfset session.searches[SearchID].CouldYou.Air[CouldYouDate] = nTotalPrice EQ 0 ? 'Flight Does not Operate' : nTotalPrice />
		<cfelse>
			<cfset nTotalPrice = session.searches[SearchID].CouldYou.Air[CouldYouDate] />
		</cfif>

		<cfset nTotalPrice = doTotalPrice(arguments.SearchID,arguments.nTripDay,arguments.nTotal) />

		<cfreturn nTotalPrice>
	</cffunction>

<!---
doHotelPriceCouldYou
--->
	<cffunction name="doHotelPriceCouldYou" output="false" access="remote" returnformat="json">
		<cfargument name="SearchID /">
		<cfargument name="nHotelCode" />
		<cfargument name="sHotelChain" />
		<cfargument name="nTripDay"		default="0" />
		<cfargument name="nNights" />
		<cfargument name="nTotal" />
		<cfargument name="stAccount" 	default="#application.Accounts[session.AcctID]#" />

		<cfset local.Search 			= getSearch(arguments.SearchID) />
		<cfset local.CouldYouDate = CreateODBCDate(DateAdd('d',nTripDay,Search.Depart_DateTime)) />

		<cfif NOT structKeyExists(session.searches[SearchID].CouldYou.Hotel,CouldYouDate)>
			<cfset hotelprice = application.objHotelPrice.doHotelPrice(arguments.SearchID,arguments.nHotelCode,arguments.sHotelChain,arguments.nHotelCode) />
			<cfset local.nhotelprice = hotelprice[1] * arguments.nNights />
			<cfset session.searches[SearchID].CouldYou.Hotel[CouldYouDate] = nhotelprice />
		<cfelse>
			<cfset nhotelprice = session.searches[SearchID].CouldYou.Hotel[CouldYouDate] />
		</cfif>

		<cfset nhotelprice = doTotalPrice(arguments.SearchID,arguments.nTripDay,arguments.nTotal) />

		<cfreturn nhotelprice>
	</cffunction>

<!---
doCarPriceCouldYou
--->
	<cffunction name="doCarPriceCouldYou" output="false" access="remote" returnformat="json">
		<cfargument name="SearchID" />
		<cfargument name="nTripDay"		default="0" />
		<cfargument name="nNights" />
		<cfargument name="sCarChain" />
		<cfargument name="sCarType" />
		<cfargument name="nTotal" />
		<cfargument name="stAccount" 	default="#application.Accounts[session.AcctID]#" />

		<cfset local.Search 			= getSearch(arguments.SearchID) />
		<cfset local.CouldYouDate = CreateODBCDate(DateAdd('d',nTripDay,Search.Depart_DateTime)) />


		<cfif NOT structKeyExists(session.searches[SearchID].CouldYou.Car,CouldYouDate)>
			<cfset CarAvailability = application.objCar.doAvailability(arguments.SearchID,arguments.nTripDay) />
			<cfset local.CarStruct = CarAvailability[arguments.sCarType][arguments.sCarChain] />
			<cfset local.nCarPrice = Mid(CarStruct.EstimatedTotalAmount,4) />
			<cfset session.searches[SearchID].CouldYou.Car[CouldYouDate] = nCarPrice />
		<cfelse>
			<cfset nCarPrice = session.searches[SearchID].CouldYou.Car[CouldYouDate] />
		</cfif>

		<cfset nCarPrice = doTotalPrice(arguments.SearchID,arguments.nTripDay,arguments.nTotal) />

		<cfreturn nCarPrice>
	</cffunction>

<!---
doTotalPrice
--->
	<cffunction name="doTotalPrice" output="false">
		<cfargument name="SearchID" />
		<cfargument name="nTripDay"		default="0" />
		<cfargument name="nTotal" />

		<cfset local.SearchID 		= arguments.SearchID />
		<cfset local.Search 			= getSearch(SearchID) />
		<cfset local.CouldYouDate = CreateODBCDate(DateAdd('d',nTripDay,Search.Depart_DateTime)) />
		<cfset local.Air 				= session['Searches'][SearchID]['Air'] />
		<cfset local.Car 				= session['Searches'][SearchID]['Car'] />
		<cfset local.Hotel				= session['Searches'][SearchID]['Hotel'] />
		<cfset local.count 				= 0 />
		<cfset local.nTotalPrice 	= 0 />
		<cfset local.stTotalPrice = {} />

		<cfset local.aTypes = [] />
		<cfset Air ? arrayAppend(aTypes,'Air') : '' />
		<cfset Car ? arrayAppend(aTypes,'Car') : '' />
		<cfset Hotel ? arrayAppend(aTypes,'Hotel') : '' />
		<cfset local.nTypes = arrayLen(aTypes) />

		<cfloop array="#aTypes#" index="local.Type">
			<cfif structKeyExists(session.searches[SearchID].CouldYou,Type) AND structKeyExists(session.searches[SearchID].CouldYou[Type],CouldYouDate)>
				<cfif isNumeric(nTotalPrice)>
					<cfif isNumeric(session.searches[SearchID].CouldYou[Type][CouldYouDate])>
						<cfset nTotalPrice+=session.searches[SearchID].CouldYou[Type][CouldYouDate] />
					<cfelse>
						<cfset nTotalPrice = session.searches[SearchID].CouldYou[Type][CouldYouDate] />
					</cfif>
				<cfelse>
					<cfif NOT isNumeric(session.searches[SearchID].CouldYou[Type][CouldYouDate])>
						<cfset nTotalPrice&= session.searches[SearchID].CouldYou[Type][CouldYouDate] />
					</cfif>
				</cfif>
				<cfset local.count++ />
			</cfif>
		</cfloop>
		<!--- Min Weekday fare - 99CC99 --->
		<cfif nTypes EQ count>
			<cfset local.stTotalPrice.nTotalPrice = nTotalPrice />
			<cfif isNumeric(nTotalPrice)>
				<cfif nTotalPrice GTE nTotal>
					<cfset local.stTotalPrice.sDifference = 'Higher/Same' />
					<cfset local.stTotalPrice.sColor = 'FFCCCC' />
				<cfelse>
					<cfset local.stTotalPrice.sDifference = 'Lower' />
					<cfset local.stTotalPrice.sColor = 'A3C8ED' />
				</cfif>
			<cfelse>
				<cfset local.stTotalPrice.sDifference = 'Not available' />
				<cfset local.stTotalPrice.sColor = 'CCCCCC' />
			</cfif>
		</cfif>
		<cfset local.stTotalPrice.Day = DateFormat(CouldYouDate,'d') />

		<cfreturn stTotalPrice />
	</cffunction>

<!--- getsearch --->
	<cffunction name="getsearch" output="false">
		<cfargument name="SearchID">

		<cfquery name="local.getsearch" datasource="book" cachedwithin="#createTimeSpan(1,0,0,0)#">
		SELECT Depart_DateTime
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.SearchID#" cfsqltype="cf_sql_numeric" />
		</cfquery>

		<cfreturn getsearch />
	</cffunction>

</cfcomponent>