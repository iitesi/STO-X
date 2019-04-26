<cfcomponent extends="abstract" accessors="true">

	<cfproperty name="purchase" setter="true" getter="false">

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<cfset TravelerNumber = 1>

		<!--- <cfdump var=#session.searches[rc.SearchID].stItinerary# abort> --->

		<cfset var Sell = purchase.doPurchase(Filter = session.filters[rc.SearchID],
											Traveler = session.searches[rc.searchID].Travelers[TravelerNumber],
											Itinerary = session.searches[rc.SearchID].stItinerary,
											LowestFare = structKeyExists(session, 'LowestFare') ? session.LowestFare : 0)>

		<cfset session.searches[SearchId].Sell = Sell>
		
		<cfif Sell.Messages.HasErrors>
			<cfset fw.redirect('summary?SearchID=#arguments.rc.SearchID#')>
		<cfelse>
			<cfset fw.redirect('confirmation?SearchID=#arguments.rc.SearchID#')>
		</cfif>

	</cffunction>

	<cffunction name="CancelTrip" output="false">
		<cfargument name="rc">

		<cfset rc.Sell = session.searches[SearchId].Sell>
		<cfset var cancelled = false>

		<cfif structKeyExists(rc, 'CancelTrip')
			AND rc.CancelTrip EQ rc.Sell.RecordLocator.UniversalRecordLocatorCode>

			<cfset var CancelResponse = purchase.CancelTrip( AcctId = session.AcctId,
															UniversalRecordLocatorCode = rc.Sell.RecordLocator.UniversalRecordLocatorCode,
															SearchId = rc.SearchId)>

			<cfif structKeyExists(CancelResponse, 'IsSuccessfullyCancelled')
				AND (CancelResponse.IsSuccessfullyCancelled
				OR CancelResponse.CancellationDetail EQ 'Record Locator has already been canceled')>

				<cfset cancelled = true>
				<cfset structDelete(session.searches[SearchId], 'Sell')>
				
			<cfelse>

				<cfset cancelled = CancelResponse.CancellationDetail>
				<cfdump var=#CancelResponse# abort>

			</cfif>

		</cfif>
		
		<cfset fw.redirect('confirmation?SearchID=#arguments.rc.SearchID#&cancelled=#cancelled#')>

	</cffunction>

</cfcomponent>