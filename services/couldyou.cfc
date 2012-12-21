<cfcomponent>
<!---
doAirPriceCouldYou
--->
	<cffunction name="doAirPriceCouldYou" output="false">
		<cfargument name="nSearchID" 		required="true">
		<cfargument name="sCabin" 			required="false"	default="Y"><!--- Options (one item) - Economy, Y, Business, C, First, F --->
		<cfargument name="bRefundable"	required="false"	default="0"><!--- Options (one item) - 0, 1 --->
		<cfargument name="nTrip"				required="false"	default="">
		<cfargument name="nTripDay"			required="false"	default="0">
		<cfargument name="stAccount" 		required="false"	default="#application.stAccounts[session.Acct_ID]#">

		<cfset local.nTripDay = arguments.nTripDay />
		<cfset local.stTrip = '' />
		<cfset local.nTotalPrice = 0 />

		<cfinvoke component="booking.services.airprice" method="doAirPrice" nSearchID="#url.Search_ID#"
		nTrip="#arguments.nTrip#" sCabin="#arguments.sCabin#" bRefundable="#arguments.bRefundable#" nCouldYou="#arguments.nTripDay#" returnvariable="nTripKey">			

		<cfloop array="#nTripKey#" index="Element">
			<cfif Element.xmlName EQ 'air:AirPriceResult'>
				<cfset stTrip = Element.XMLChildren.1.XMLAttributes />
			  <cfset nTotalPrice = Mid(stTrip.TotalPrice, 4)>
			</cfif>
		</cfloop>		

		<cfreturn nTotalPrice>
	</cffunction>
	
</cfcomponent>