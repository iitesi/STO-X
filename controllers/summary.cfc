<cfcomponent>

	<cfset variables.fw = "">
	<cffunction name="init" output="false" returntype="any">
		<cfargument name="fw">
		<cfset variables.fw = arguments.fw>
		<cfreturn this>
	</cffunction>
	
<!---
default
--->
	<cffunction name="default" output="false">
		<cfargument name="rc">
		
		<cfset variables.fw.service('summary.determinFees', 'stFees')>
		<cfset variables.fw.service('summary.getOutOfPolicy', 'qOutOfPolicy')>
		<cfif session.Acct_ID EQ 235>
			<cfset variables.fw.service('summary.getTXExceptionCodes', 'qTXExceptionCodes')>
		</cfif>
		<cfset variables.fw.service('summary.getUser', 'qUser')>
		<cfset variables.fw.service('summary.getAllTravelers', 'qAllTravelers')>

		<cfset local.stY1 = {}>
		<cfset stY1.sCabin = 'Y'>
		<cfset stY1.bRefundable = 1>
		<cfset stY1.nTrip = session.searches[rc.nSearchID].stItinerary.Air.nTrip>
		<cfset variables.fw.service('airprice.doAirPrice', 'nY1TripKey', stY1)>
		
		<cfset local.stC0 = {}>
		<cfset stC0.sCabin = 'C'>
		<cfset stC0.bRefundable = 0>
		<cfset stC0.nTrip = session.searches[rc.nSearchID].stItinerary.Air.nTrip>
		<cfset variables.fw.service('airprice.doAirPrice', 'nC0TripKey', stC0)>

		<cfreturn />
	</cffunction>
	
</cfcomponent>