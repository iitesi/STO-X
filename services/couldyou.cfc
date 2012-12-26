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

		<!--- <cfif NOT structKeyExists(session.searches[url.Search_ID].CouldYou.Air,CouldYouDate)> --->
			<cfinvoke component="booking.services.airprice" method="doAirPrice" nSearchID="#arguments.nSearchID#"
			nTrip="#arguments.nTrip#" sCabin="#arguments.sCabin#" bRefundable="#arguments.bRefundable#" nCouldYou="#arguments.nTripDay#" returnvariable="nTripKey">			

			<cfloop array="#nTripKey#" index="Element">
				<cfif Element.xmlName EQ 'air:AirPriceResult'>
					<cfset stTrip = Element.XMLChildren.1.XMLAttributes />
				  <cfset nTotalPrice = Mid(stTrip.TotalPrice, 4)>
				</cfif>
			</cfloop>		
			<cfset session.searches[nSearchID].CouldYou.Air[CouldYouDate] = nTotalPrice />
		<!--- <cfelse>
			<cfset nTotalPrice = session.searches[url.Search_ID].CouldYou.Air[CouldYouDate] />
		</cfif> --->
		
		<cfreturn nTotalPrice>
	</cffunction>
	
</cfcomponent>