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
		<cfset CouldYouDate = DateAdd('d',nTripDay,session.searches[nSearchID].stItinerary.Air.Depart) />

		<cfif NOT structKeyExists(session.searches[nSearchID].CouldYou,'Air') OR NOT structKeyExists(session.searches[nSearchID].CouldYou.Air,CouldYouDate)>
			<cfinvoke component="booking.services.airprice" method="doAirPrice" nSearchID="#arguments.nSearchID#"
			nTrip="#arguments.nTrip#" sCabin="#arguments.sCabin#" bRefundable="#arguments.bRefundable#" nCouldYou="#arguments.nTripDay#" returnvariable="nTripKey">			

			<cfloop array="#nTripKey#" index="Element">
				<cfif Element.xmlName EQ 'air:AirPriceResult'>
					<cfset stTrip = Element.XMLChildren.1.XMLAttributes />
				  <cfset nTotalPrice = Mid(stTrip.TotalPrice, 4)>
				</cfif>
			</cfloop>		
			<cfset session.searches[nSearchID].CouldYou.Air[CouldYouDate] = nTotalPrice />
		<cfelse>
			<cfset nTotalPrice = session.searches[nSearchID].CouldYou.Air[CouldYouDate] />
		</cfif>

		<cfif nTotalPrice EQ 0>
			<cfset nTotalPrice = 'Flight Does not Operate' />
		</cfif>

		<cfif isNumeric(nTotalPrice) AND structKeyExists(session.searches[nSearchID].CouldYou.Hotel,CouldYouDate)>
			<cfset nTotalPrice+=session.searches[nSearchID].CouldYou.Hotel[CouldYouDate] />			
		</cfif>
		
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

		<cfset local.CouldYouDate = DateAdd('d',nTripDay,session.searches[nSearchID].stItinerary.Hotel.CheckIn) />

		<cfif NOT structKeyExists(session.searches[nSearchID].CouldYou.Hotel,CouldYouDate)>
			<cfinvoke component="booking.services.hotelprice" method="doHotelPrice" nSearchID="#arguments.nSearchID#" nHotelCode="#arguments.nHotelCode#" sHotelChain="#arguments.sHotelChain#" nCouldYou="#arguments.nTripDay#" returnvariable="hotelprice">
			<cfset local.nhotelprice = hotelprice[1] * arguments.nNights />
			<cfset session.searches[nSearchID].CouldYou.Hotel[CouldYouDate] = nhotelprice />
		<cfelse>
			<cfset nhotelprice = session.searches[nSearchID].CouldYou.Hotel[CouldYouDate] />
		</cfif> 
		
		<cfif structKeyExists(session.searches[nSearchID].CouldYou,'Air') AND structKeyExists(session.searches[nSearchID].CouldYou.Air,CouldYouDate)>
			<cfif isNumeric(session.searches[nSearchID].CouldYou.Air[CouldYouDate]) AND session.searches[nSearchID].CouldYou.Air[CouldYouDate] NEQ 0>
				<cfset nhotelprice+=session.searches[nSearchID].CouldYou.Air[CouldYouDate] />
			</cfif>
		</cfif>

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

		<cfset local.CouldYouDate = DateAdd('d',nTripDay,session.searches[nSearchID].stItinerary.Air.Depart) />

		<cfif NOT structKeyExists(session.searches[nSearchID].CouldYou.Car,CouldYouDate)>
			<cfinvoke component="booking.services.car" method="doAvailability" nSearchID="#arguments.nSearchID#" nCouldYou="#arguments.nTripDay#" returnvariable="CarAvailability">			
			<cfset local.CarStruct = CarAvailability[arguments.sCarType][arguments.sCarChain] />
			<cfset local.nCarPrice = Mid(CarStruct.EstimatedTotalAmount,4) />
			<cfset session.searches[nSearchID].CouldYou.Car[CouldYouDate] = nCarPrice />
		<cfelse>
			<cfset nCarPrice = session.searches[nSearchID].CouldYou.Car[CouldYouDate] />
		</cfif> 
		
		<!--- <cfif structKeyExists(session.searches[nSearchID].CouldYou,'Air') AND structKeyExists(session.searches[nSearchID].CouldYou.Air,CouldYouDate)>
			<cfif isNumeric(session.searches[nSearchID].CouldYou.Air[CouldYouDate]) AND session.searches[nSearchID].CouldYou.Air[CouldYouDate] NEQ 0>
				<cfset nhotelprice+=session.searches[nSearchID].CouldYou.Air[CouldYouDate] />
			</cfif>
		</cfif> --->

		<cfreturn nCarPrice>
	</cffunction>
	
</cfcomponent>