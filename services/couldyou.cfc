<cfcomponent>

<!---
doAirPriceCouldYou
--->
	<cffunction name="doAirPriceCouldYou" output="false" access="remote" returnformat="json">
		<cfargument name="nSearchID" 		required="true" />
		<cfargument name="sCabin" 			required="false"	default="Y" /><!--- Options (one item) - Economy, Y, Business, C, First, F --->
		<cfargument name="bRefundable"	required="false"	default="0" /><!--- Options (one item) - 0, 1 --->
		<cfargument name="nTrip"				required="false"	default="" />
		<cfargument name="nTripDay"			required="false"	default="0" />
		<cfargument name="StartDate"		required="false"	default="" />
		<cfargument name="nTotal" />
		<cfargument name="stAccount" 		required="false"	default="#application.stAccounts[session.Acct_ID]#" />

		<cfset local.stTrip = '' />
		<cfset local.nTotalPrice = 0 />
		<cfset local.Search 			= getSearch(arguments.nSearchID) />
		<cfset local.CouldYouDate = CreateODBCDate(DateAdd('d',arguments.nTripDay,Search.Depart_DateTime)) />

		<cfif NOT structKeyExists(session.searches[nSearchID].CouldYou,'Air') OR NOT structKeyExists(session.searches[nSearchID].CouldYou.Air,CouldYouDate)>
			<cfset local.nTripKey = application.objAirPrice.doAirPrice(arguments.nSearchID,arguments.sCabin,arguments.bRefundable,arguments.nTrip,arguments.nTripDay) />

			<cfloop array="#nTripKey#" index="local.Element">
				<cfif Element.xmlName EQ 'air:AirPriceResult'>
					<cfset local.stTrip = Element.XMLChildren.1.XMLAttributes />
				  <cfset local.nTotalPrice = Mid(stTrip.TotalPrice, 4)>
				</cfif>
			</cfloop>

			<cfset session.searches[nSearchID].CouldYou.Air[CouldYouDate] = nTotalPrice EQ 0 ? 'Flight Does not Operate' : nTotalPrice />
		<cfelse>
			<cfset local.nTotalPrice = session.searches[nSearchID].CouldYou.Air[CouldYouDate] />
		</cfif>	

		<cfset local.nTotalPrice = doTotalPrice(arguments.nSearchID,arguments.nTripDay,arguments.nTotal) />
		
		<cfreturn nTotalPrice>
	</cffunction>

<!---
doHotelPriceCouldYou
--->
	<cffunction name="doHotelPriceCouldYou" output="false" access="remote" returnformat="json">
		<cfargument name="nSearchID /">
		<cfargument name="nHotelCode" />
		<cfargument name="sHotelChain" />
		<cfargument name="nTripDay"		default="0" />
		<cfargument name="nNights" />
		<cfargument name="nTotal" />
		<cfargument name="stAccount" 	default="#application.stAccounts[session.Acct_ID]#" />

		<cfset local.Search 			= getSearch(arguments.nSearchID) />
		<cfset local.CouldYouDate = CreateODBCDate(DateAdd('d',nTripDay,Search.Depart_DateTime)) />

		<cfif NOT structKeyExists(session.searches[nSearchID].CouldYou.Hotel,CouldYouDate)>
			<cfset local.hotelprice = application.objHotelPrice.doHotelPrice(arguments.nSearchID,arguments.nHotelCode,arguments.sHotelChain,arguments.nHotelCode) />
			<cfset local.nhotelprice = hotelprice[1] * arguments.nNights />
			<cfset session.searches[nSearchID].CouldYou.Hotel[CouldYouDate] = nhotelprice />
		<cfelse>
			<cfset local.nhotelprice = session.searches[nSearchID].CouldYou.Hotel[CouldYouDate] />
		</cfif> 
		
		<cfset local.nhotelprice = doTotalPrice(arguments.nSearchID,arguments.nTripDay,arguments.nTotal) />

		<cfreturn nhotelprice>
	</cffunction>

<!---
doCarPriceCouldYou
--->
	<cffunction name="doCarPriceCouldYou" output="false" access="remote" returnformat="json">
		<cfargument name="nSearchID" />
		<cfargument name="nTripDay"		default="0" />
		<cfargument name="nNights" />
		<cfargument name="sCarChain" />
		<cfargument name="sCarType" />
		<cfargument name="nTotal" />
		<cfargument name="stAccount" 	default="#application.stAccounts[session.Acct_ID]#" />

		<cfset local.Search 			= getSearch(arguments.nSearchID) />
		<cfset local.CouldYouDate = CreateODBCDate(DateAdd('d',nTripDay,Search.Depart_DateTime)) />

		<cfif NOT structKeyExists(session.searches[nSearchID].CouldYou.Car,CouldYouDate)>
			<cfset local.CarAvailability = application.objCar.doAvailability(arguments.nSearchID,arguments.nTripDay) />
			<cfset local.CarStruct = CarAvailability[arguments.sCarType][arguments.sCarChain] />
			<cfset local.nCarPrice = Mid(CarStruct.EstimatedTotalAmount,4) />
			<cfset session.searches[nSearchID].CouldYou.Car[CouldYouDate] = nCarPrice />
		<cfelse>
			<cfset local.nCarPrice = session.searches[nSearchID].CouldYou.Car[CouldYouDate] />
		</cfif>

		<cfset local.nCarPrice = doTotalPrice(arguments.nSearchID,arguments.nTripDay,arguments.nTotal) />

		<cfreturn nCarPrice>
	</cffunction>

<!---
doTotalPrice
--->
	<cffunction name="doTotalPrice" output="false">
		<cfargument name="nSearchID" />
		<cfargument name="nTripDay"		default="0" />
		<cfargument name="nTotal" />
		
		<cfset local.nSearchID 		= arguments.nSearchID />
		<cfset local.Search 			= getSearch(nSearchID) />
		<cfset local.CouldYouDate = CreateODBCDate(DateAdd('d',nTripDay,Search.Depart_DateTime)) />
		<cfset local.bAir 				= session['Searches'][nSearchID]['bAir'] />
		<cfset local.bCar 				= session['Searches'][nSearchID]['bCar'] />
		<cfset local.bHotel				= session['Searches'][nSearchID]['bHotel'] />
		<cfset local.count 				= 0 />
		<cfset local.nTotalPrice 	= 0 />
		<cfset local.stTotalPrice = {} />

		<cfset local.aTypes = [] />
		<cfset bAir ? arrayAppend(aTypes,'Air') : '' />
		<cfset bCar ? arrayAppend(aTypes,'Car') : '' />
		<cfset bHotel ? arrayAppend(aTypes,'Hotel') : '' />
		<cfset local.nTypes = arrayLen(aTypes) />

		<cfloop array="#aTypes#" index="local.Type">
			<cfif structKeyExists(session.searches[nSearchID].CouldYou,Type) AND structKeyExists(session.searches[nSearchID].CouldYou[Type],CouldYouDate)>
				<cfif isNumeric(nTotalPrice)>					
					<cfif isNumeric(session.searches[nSearchID].CouldYou[Type][CouldYouDate])>
						<cfset local.nTotalPrice+=session.searches[nSearchID].CouldYou[Type][CouldYouDate] />
					<cfelse>
						<cfset local.nTotalPrice = session.searches[nSearchID].CouldYou[Type][CouldYouDate] />
					</cfif>
				<cfelse>
					<cfif NOT isNumeric(session.searches[nSearchID].CouldYou[Type][CouldYouDate])>
						<cfset local.nTotalPrice&= session.searches[nSearchID].CouldYou[Type][CouldYouDate] />
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
		<cfargument name="nSearchID">

		<cfquery name="local.getsearch" datasource="book" cachedwithin="#createTimeSpan(1,0,0,0)#">
		SELECT Depart_DateTime
		FROM Searches
		WHERE Search_ID = <cfqueryparam value="#arguments.nSearchID#" cfsqltype="cf_sql_numeric" />
		</cfquery>
		
		<cfreturn getsearch />
	</cffunction>

</cfcomponent>