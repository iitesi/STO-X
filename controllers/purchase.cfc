<cfcomponent extends="abstract" accessors="true">

	<cfproperty name="purchase" setter="true" getter="false">

	<cffunction name="default" output="false">
		<cfargument name="rc">

		<cfset var Travelers = session.searches[rc.SearchID].Travelers>
		<cfset var Successful = true>

		<cfloop collection="#Travelers#" index="local.TravelerIndex" item="local.Traveler">

			<cfif Successful>

				<cfset var Sell = purchase.doPurchase(Filter = session.filters[rc.SearchID],
													Traveler = Traveler,
													Itinerary = session.searches[rc.SearchID].stItinerary,
													LowestFare = structKeyExists(session, 'LowestFare') ? session.LowestFare : 0)>

				<cfif NOT Sell.Messages.HasErrors>

					<cfset session.searches[SearchId].Sell[TravelerIndex] = Sell>
					<cfset session.searches[SearchId].Sell[TravelerIndex].Cancelled = false>
					<cfset session.searches[SearchId].Sell[TravelerIndex].CancellationDetail = ''>

				<cfelse>

					<cfloop collection="#Travelers#" index="local.TravelerIndex" item="local.Traveler">

						<cfif structKeyExists(session.searches[SearchId], 'Sell')
							AND structKeyExists(session.searches[SearchId].Sell, TravelerIndex)
							AND structKeyExists(session.searches[SearchId].Sell[TravelerIndex], 'RecordLocator')>

							<cfset var CancelResponse = purchase.CancelTrip( AcctId = session.AcctId,
																			UniversalRecordLocatorCode = rc.Sell.RecordLocator.UniversalRecordLocatorCode,
																			SearchId = rc.SearchId)>

							<cfif structKeyExists(CancelResponse, 'IsSuccessfullyCancelled')
								AND (CancelResponse.IsSuccessfullyCancelled
								OR CancelResponse.CancellationDetail EQ 'Record Locator has already been canceled')>

								<cfset session.searches[SearchId].Sell[TravelerIndex].Cancelled = true>
								<cfset session.searches[SearchId].Sell[TravelerIndex].CancellationDetail = CancelResponse.CancellationDetail>
								
							<cfelse>

								<cfset session.searches[SearchId].Sell[TravelerIndex].Cancelled = false>
								<cfset session.searches[SearchId].Sell[TravelerIndex].CancellationDetail = CancelResponse.CancellationDetail>

							</cfif>

						</cfif>

						<cfset Successful = false>

					</cfloop>

				</cfif>

			</cfif>

		</cfloop>
		
		<cfif Successful>
			<cfset fw.redirect('confirmation?SearchID=#arguments.rc.SearchID#')>
		<cfelse>
			<cfset fw.redirect('summary?SearchID=#arguments.rc.SearchID#')>
		</cfif>

	</cffunction>

	<cffunction name="CancelTrip" output="false">
		<cfargument name="rc">

		<cfset rc.Sell = session.searches[SearchId].Sell[rc.TravelerNumber]>
		<cfset var cancelled = false>

		<cfif structKeyExists(rc, 'CancelTrip')
			AND rc.CancelTrip EQ rc.Sell.RecordLocator.UniversalRecordLocatorCode>

			<cfset var CancelResponse = purchase.CancelTrip( AcctId = rc.AcctId,
															UniversalRecordLocatorCode = rc.Sell.RecordLocator.UniversalRecordLocatorCode,
															SearchId = rc.SearchId)>

			<cfif structKeyExists(CancelResponse, 'IsSuccessfullyCancelled')
				AND (CancelResponse.IsSuccessfullyCancelled
				OR CancelResponse.CancellationDetail EQ 'Record Locator has already been canceled')>

				<cfset session.searches[SearchId].Sell[rc.TravelerNumber].Cancelled = true>
				<cfset session.searches[SearchId].Sell[rc.TravelerNumber].CancellationDetail = CancelResponse.CancellationDetail>
				
			<cfelse>

				<cfset session.searches[SearchId].Sell[rc.TravelerNumber].Cancelled = false>
				<cfset session.searches[SearchId].Sell[rc.TravelerNumber].CancellationDetail = CancelResponse.CancellationDetail>

			</cfif>

		</cfif>

		<cfset fw.redirect('confirmation?SearchID=#arguments.rc.SearchID#')>

	</cffunction>

</cfcomponent>