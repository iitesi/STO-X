<cfcomponent extends="abstract" accessors="true">

	<cfproperty name="purchase" setter="true" getter="false">

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<cfset TravelerNumber = 1>

		<!--- <cfdump var=#session.searches[rc.SearchID].stItinerary# abort> --->

		<cfset session.searches[SearchId].Sell = purchase.doPurchase(Filter = session.filters[rc.SearchID],
																	Traveler = session.searches[rc.searchID].Travelers[TravelerNumber],
																	Itinerary = session.searches[rc.SearchID].stItinerary)>
		
		<cfset fw.redirect('confirmation?SearchID=#arguments.rc.SearchID#')>

	</cffunction>

	<cffunction name="CancelTrip" output="false">
		<cfargument name="rc">

		<cfset rc.Sell = session.searches[SearchId].Sell>

		<cfif structKeyExists(rc, 'CancelTrip')
			AND rc.CancelTrip EQ rc.Sell.RecordLocator.UniversalRecordLocatorCode>

			<cfset var CancelResponse = purchase.CancelTrip( AcctId = session.AcctId,
															UniversalRecordLocatorCode = rc.Sell.RecordLocator.UniversalRecordLocatorCode,
															SearchId = rc.SearchId)>

			<cfif structKeyExists(CancelResponse, 'IsSuccessfullyCancelled')
			AND CancelResponse.IsSuccessfullyCancelled>

				<cfset var cancelled = true>

			<cfelse>

				<cfset var cancelled = CancelResponse.CancellationDetail>
				<cfdump var=#CancelResponse# abort>

			</cfif>

		</cfif>
		
		<cfset fw.redirect('confirmation?SearchID=#arguments.rc.SearchID#')>

	</cffunction>

</cfcomponent>