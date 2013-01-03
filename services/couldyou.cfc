<cfcomponent>

<!---
doAirPriceCouldYou
--->
	<cffunction name="doAirPriceCouldYou" output="false" access="remote" returnformat="json">
		<cfargument name="nSearchID" 		required="true">
		<cfargument name="sCabin" 			required="false"	default="Y"><!--- Options (one item) - Economy, Y, Business, C, First, F --->
		<cfargument name="bRefundable"	required="false"	default="0"><!--- Options (one item) - 0, 1 --->
		<cfargument name="nTrip"				required="false"	default="">
		<cfargument name="nTripDay"			required="false"	default="0">
		<cfargument name="StartDate"		required="false"	default="">
		<cfargument name="stAccount" 		required="false"	default="#application.stAccounts[session.Acct_ID]#">

		<cfset local.nTripDay = arguments.nTripDay />
		<cfset local.stTrip = '' />
		<cfset local.nTotalPrice = 0 />
		<cfset local.CouldYouDate = CreateODBCDate(DateAdd('d',nTripDay,session.searches[nSearchID].stItinerary.Air.Depart)) />

		<cfif NOT structKeyExists(session.searches[nSearchID].CouldYou,'Air') OR NOT structKeyExists(session.searches[nSearchID].CouldYou.Air,CouldYouDate)>
			<cfinvoke component="booking.services.airprice" method="doAirPrice" nSearchID="#arguments.nSearchID#"
			nTrip="#arguments.nTrip#" sCabin="#arguments.sCabin#" bRefundable="#arguments.bRefundable#" nCouldYou="#arguments.nTripDay#" returnvariable="nTripKey">			

			<cfloop array="#nTripKey#" index="Element">
				<cfif Element.xmlName EQ 'air:AirPriceResult'>
					<cfset stTrip = Element.XMLChildren.1.XMLAttributes />
				  <cfset nTotalPrice = Mid(stTrip.TotalPrice, 4)>
				</cfif>
			</cfloop>

			<cfset session.searches[nSearchID].CouldYou.Air[CouldYouDate] = nTotalPrice EQ 0 ? 'Flight Does not Operate' : nTotalPrice /> <!--- --->
		<cfelse>
			<cfset nTotalPrice = session.searches[nSearchID].CouldYou.Air[CouldYouDate] />
		</cfif>	

		<cfset nTotalPrice = doTotalPrice(arguments.nSearchID,arguments.nTripDay) />
		
		<cfreturn nTotalPrice>
	</cffunction>

<!---
doHotelPriceCouldYou
--->
	<cffunction name="doHotelPriceCouldYou" output="false" access="remote" returnformat="json">
		<cfargument name="nSearchID">
		<cfargument name="nHotelCode">
		<cfargument name="sHotelChain">
		<cfargument name="nTripDay"		default="0">
		<cfargument name="nNights">
		<cfargument name="stAccount" 	default="#application.stAccounts[session.Acct_ID]#">

		<cfset local.CouldYouDate = CreateODBCDate(DateAdd('d',nTripDay,session.searches[nSearchID].stItinerary.Hotel.CheckIn)) />

		<cfif NOT structKeyExists(session.searches[nSearchID].CouldYou.Hotel,CouldYouDate)>
			<cfinvoke component="booking.services.hotelprice" method="doHotelPrice" nSearchID="#arguments.nSearchID#" nHotelCode="#arguments.nHotelCode#" sHotelChain="#arguments.sHotelChain#" nCouldYou="#arguments.nTripDay#" returnvariable="hotelprice">
			<cfset local.nhotelprice = hotelprice[1] * arguments.nNights />
			<cfset session.searches[nSearchID].CouldYou.Hotel[CouldYouDate] = nhotelprice />
		<cfelse>
			<cfset nhotelprice = session.searches[nSearchID].CouldYou.Hotel[CouldYouDate] />
		</cfif> 
		
		<cfset nhotelprice = doTotalPrice(arguments.nSearchID,arguments.nTripDay) />

		<cfreturn nhotelprice>
	</cffunction>

<!---
doCarPriceCouldYou
--->
	<cffunction name="doCarPriceCouldYou" output="false" access="remote" returnformat="json">
		<cfargument name="nSearchID">
		<cfargument name="nTripDay"		default="0">
		<cfargument name="nNights">
		<cfargument name="sCarChain">
		<cfargument name="sCarType">
		<cfargument name="stAccount" 	default="#application.stAccounts[session.Acct_ID]#">

		<cfset local.CouldYouDate = CreateODBCDate(DateAdd('d',nTripDay,session.searches[nSearchID].stItinerary.Air.Depart)) />

		<cfif NOT structKeyExists(session.searches[nSearchID].CouldYou.Car,CouldYouDate)>
			<cfinvoke component="booking.services.car" method="doAvailability" nSearchID="#arguments.nSearchID#" nCouldYou="#arguments.nTripDay#" returnvariable="CarAvailability">			
			<cfset local.CarStruct = CarAvailability[arguments.sCarType][arguments.sCarChain] />
			<cfset local.nCarPrice = Mid(CarStruct.EstimatedTotalAmount,4) />
			<cfset session.searches[nSearchID].CouldYou.Car[CouldYouDate] = nCarPrice />
		<cfelse>
			<cfset nCarPrice = session.searches[nSearchID].CouldYou.Car[CouldYouDate] />
		</cfif>

		<cfset nCarPrice = doTotalPrice(arguments.nSearchID,arguments.nTripDay) />

		<cfreturn nCarPrice>
	</cffunction>

<!---
doTotalPrice
--->
	<cffunction name="doTotalPrice" output="false">
		<cfargument name="nSearchID">
		<cfargument name="nTripDay"		default="0">

		<cfset local.CouldYouDate = CreateODBCDate(DateAdd('d',nTripDay,session.searches[arguments.nSearchID].stItinerary.Air.Depart)) />
		<cfset local.bAir 				= session['Searches'][arguments.nSearchID]['bAir'] />
		<cfset local.bCar 				= session['Searches'][arguments.nSearchID]['bCar'] />
		<cfset local.bHotel				= session['Searches'][arguments.nSearchID]['bHotel'] />

		<cfset local.aTypes = [] />
		<cfset bAir ? arrayAppend(aTypes,'Air') : '' />
		<cfset bCar ? arrayAppend(aTypes,'Car') : '' />
		<cfset bHotel ? arrayAppend(aTypes,'Hotel') : '' />

		<cfset local.nTypes 			= arrayLen(aTypes) />
		<cfset local.count 				= 0 />
		<cfset local.nTotalPrice 	= 0 />
		<cfloop array="#aTypes#" index="Type">
			<cfif structKeyExists(session.searches[nSearchID].CouldYou,Type) AND structKeyExists(session.searches[nSearchID].CouldYou[Type],CouldYouDate)>
				<cfif isNumeric(nTotalPrice)>					
					<cfif isNumeric(session.searches[nSearchID].CouldYou[Type][CouldYouDate])>
						<cfset nTotalPrice+=session.searches[nSearchID].CouldYou[Type][CouldYouDate] />
					<cfelse>
						<cfset nTotalPrice = session.searches[nSearchID].CouldYou[Type][CouldYouDate] />
					</cfif>
				<cfelse>
					<cfif NOT isNumeric(session.searches[nSearchID].CouldYou[Type][CouldYouDate])>
						<cfset nTotalPrice&= session.searches[nSearchID].CouldYou[Type][CouldYouDate] />
					</cfif>
				</cfif>
				<cfset count++ />
			</cfif>
		</cfloop>

		<cfif nTypes NEQ count>
			<cfset nTotalPrice = '' />
		</cfif>

		<cfreturn nTotalPrice />
	</cffunction>
	
</cfcomponent>