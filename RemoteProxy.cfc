<cfcomponent name="STORemoteProxy" output="false">

	<cffunction name="getAuthorizedTravelers" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="userID" type="numeric" required="true"/>
		<cfargument name="acctID" type="numeric" required="true"/>
		<cfargument name="returnFormat" type="string" required="false" default="array"/>

		<cftry>
			<cfreturn getBean( "UserService" ).getAuthorizedTravelers( argumentCollection=arguments ) />
			<cfcatch type="any">
				<cfset logError( cfcatch, arguments ) />
			</cfcatch>
		</cftry>

	</cffunction>

	<cffunction name="getUser" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="userId" type="numeric" required="true"/>

		<cftry>
			<cfreturn getBean( "UserService" ).load( arguments.userId ) />
			<cfcatch type="any">
				<cfset logError( cfcatch, arguments ) />
			</cfcatch>
		</cftry>

	</cffunction>

	<cffunction name="loadFullUser" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="userID" type="numeric" required="true"/>
		<cfargument name="acctID" type="numeric" required="true"/>
	    <cfargument name="valueID" type="numeric" required="true"/>
	    <cfargument name="arrangerID" type="numeric" required="true"/>
	    <cfargument name="vendor" type="string" required="false" default=""/>

		<cftry>
			<cfset local.Traveler = getBean( "UserService" ).loadFullUser( userID = arguments.userId
																		, acctID = arguments.acctID
																		, valueID = arguments.valueID
																		, arrangerID = arguments.arrangerID
																		, vendor = arguments.vendor)>
			<cfset local.BookingDetail = createObject('component', 'booking.model.BookingDetail').init()>
			<cfset Traveler.setBookingDetail( BookingDetail )>

			<cfreturn Traveler />

			<cfcatch type="any">
				<cfset logError( cfcatch, arguments ) />
			</cfcatch>
		</cftry>

	</cffunction>

	<cffunction name="loadOrgUnit" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="acctID" type="numeric" required="true">
		<cfargument name="valueID" type="numeric" required="true">
		<cfargument name="userID" type="numeric" required="true">

		<cftry>
			<cfreturn getBean( "OrgUnitService" ).loadOrgUnit( acctID = arguments.acctID, valueID = arguments.valueID, userID = arguments.userID ) />

			<cfcatch type="any">
				<cfset logError( cfcatch, arguments ) />
			</cfcatch>
		</cftry>

	</cffunction>

	<cffunction name="getOrgUnitValues" returntype="any" access="remote" output="false" returnformat="JSON">
		<cfargument name="ouID" required="true">
		<cfargument name="valueID" required="false" default="0">
		<cfargument name="conditionalSort1" required="false" default="">
		<cfargument name="conditionalSort2" required="false" default="">
		<cfargument name="conditionalSort3" required="false" default="">
		<cfargument name="conditionalSort4" required="false" default="">
		<cfargument name="conditionalSort5" required="false" default="">
		<cfargument name="returnFormat" type="string" required="false" default="array"/>

		<!---<cftry>--->
			<cfset local.qOrgUnitValues = getBean( "OrgUnitService" ).getOrgUnitValues( ouID = arguments.ouID
																				, valueID = arguments.valueID
																				, conditionalSort1 = arguments.conditionalSort1
																				, conditionalSort2 = arguments.conditionalSort2
																				, conditionalSort3 = arguments.conditionalSort3
																				, conditionalSort4 = arguments.conditionalSort4
																				, conditionalSort5 = arguments.conditionalSort5
																				, returnFormat = arguments.returnFormat ) />

			<cfreturn serializeJSON( qOrgUnitValues ) />

			<!---<cfcatch type="any">
				<cfset logError( cfcatch, arguments ) />
			</cfcatch>
		</cftry>--->

	</cffunction>

	<cffunction name="getUserCCEmails" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="userId" type="numeric" required="true"/>
		<cfargument name="returnType" type="string" required="false" default="struct" hint="Valid values: query|array|string"/>

		<cfreturn getBean( "UserService" ).getUserCCEmails( arguments.userId, arguments.returnType ) />
	</cffunction>

	<cffunction name="getUserTravelerNumber" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="userID" type="numeric" required="true"/>
		<cfargument name="travelNumberType" type="string" required="true"/>

		<cfreturn getBean( "UserService" ).getUserTravelerNumber( arguments.userId, arguments.travelNumberType) />
	</cffunction>

    <cffunction name="getSearch" returntype="any" access="remote" output="false" returnformat="json" hint="">
        <cfargument name="searchId" type="numeric" required="true"/>

		<cfset var result = new com.shortstravel.RemoteResponse() />

		<cftry>
			<cfset var Search = getBean( "SearchService" ).load( arguments.searchId ) />

			<cfif isNumeric( Search.getSearchID() ) AND Search.getSearchID() > 0>
				<cfset result.setData( Search ) />
			<cfelse>
				<cfset result.addError( "Unable to locate the specified search." ) />
				<cfset result.setSuccess( false ) />
			</cfif>

			<cfcatch type="any">
				<cfset result.addError( "An error occurred while retrieving the specified search." ) />
				<cfset result.setSuccess( false ) />
				<cfset logError( cfcatch, arguments ) />
			</cfcatch>

		</cftry>

        <cfreturn result />

    </cffunction>

	<cffunction name="updateSearch" access="remote" output="false" returntype="any" returnFormat="json" hint="">
		<cfargument name="searchId" type="numeric" required="true"/>
		<cfargument name="hotelRadius" type="numeric" required="false" />
		<cfargument name="hotelSearch" type="string" required="false" />
		<cfargument name="hotelLat" type="numeric" required="false" />
		<cfargument name="hotelLong" type="numeric" required="false" />
		<cfargument name="hotelAddress" type="string" required="false" />
		<cfargument name="hotelCity" type="string" required="false" />
		<cfargument name="hotelState" type="string" required="false" />
		<cfargument name="hotelZip" type="string" required="false" />
		<cfargument name="checkInDate" type="date" required="false" />
		<cfargument name="checkOutDate" type="date" required="false" />

		<cfset var result = new com.shortstravel.RemoteResponse() />

		<cftry>

			<cfset var Search = getBean( "SearchService" ).save( argumentCollection = arguments ) />
			<cfset var Filter = getBean("setup").setFilter(searchID = arguments.searchID, requery = true) />

			<cfif isNumeric( Search.getSearchID() ) AND Search.getSearchID() > 0>
				<cfset result.setData( Search ) />
			<cfelse>
				<cfset result.addError( "Unable to update the specified search." ) />
				<cfset result.setSuccess( false ) />
			</cfif>

			<cfcatch type="any">
				<cfset result.addError( "An error occurred while updating the specified search.<br>#cfcatch.message#" ) />
				<cfset result.setSuccess( false ) />
				<cfset logError( cfcatch, arguments ) />
			</cfcatch>

		</cftry>

        <cfreturn result />

	</cffunction>

    <cffunction name="getHotelSearchResults" returntype="any" access="remote" output="false" returnformat="json" hint="">
        <cfargument name="searchId" type="numeric" required="true"/>
        <cfargument name="propertyId" type="string" required="false" default="" />
		<cfargument name="requery" type="boolean" required="false" default="false" />
        <cfargument name="finditRequest" type="boolean" required="false" default="false" />

        <cfreturn getBean( "HotelService" ).search( argumentCollection=arguments ) />

    </cffunction>

    <cffunction name="getAvailableHotelRooms" returntype="any" access="remote" returnformat="plain" output="false" hint="">
        <cfargument name="searchId" type="numeric" required="true"/>
        <cfargument name="propertyId" type="string" required="true" />
        <cfargument name="callback" type="string" required="false" />
        <cfargument name="requery" type="boolean" required="false" default="false" />

		<cfset var Rooms = getBean( "HotelService" ).getAvailableRooms( argumentCollection=arguments ) />
		<cfif structKeyExists( arguments, "callback" ) AND arguments.callback NEQ "">
			<cfcontent type="application/javascript" />
			<cfsavecontent variable="local.callbackFunction">
				<cfoutput>#arguments.callback#(#serializeJSON( Rooms )#)</cfoutput>
			</cfsavecontent>
			<cfreturn callbackFunction />
		<cfelse>
			<cfreturn serializeJSON( Rooms ) />
		</cfif>

    </cffunction>

	<cffunction name="getHotelDetails" access="remote" output="false" returntype="any" returnformat="plain" hint="I get the extended details for a particular hotel">
		<cfargument name="propertyId" type="string" requred="true" />
		<cfargument name="forceUpdate" type="boolean" required="false" default="false" />
		<cfargument name="callback" type="string" required="false" />

		<cfset var result = new com.shortstravel.RemoteResponse() />

		<!---<cftry>--->
			<cfset result.setData( getBean( "HotelService" ).getExtendedHotelData( argumentCollection=arguments ) ) />

			<!---<cfcatch type="any">
				<cfset result.addError( "An error occurred while retrieving extended data for the requested hotel." ) />
				<cfset result.setSuccess( false ) />
				<cfset logError( cfcatch, arguments ) />
			</cfcatch>
		</cftry>--->

		<cfif structKeyExists( arguments, "callback" ) AND arguments.callback NEQ "">
			<cfcontent type="application/javascript" />
			<cfsavecontent variable="local.callbackFunction">
				<cfoutput>#arguments.callback#(#serializeJSON( result )#)</cfoutput>
			</cfsavecontent>
			<cfreturn callbackFunction />
		<cfelse>
			<cfreturn serializeJSON( result ) />
		</cfif>

	</cffunction>

    <cffunction name="getAccount" returntype="any" access="remote" output="false" returnformat="json" hint="">
        <cfargument name="accountId" type="numeric" required="true" />

		<cfif NOT structKeyExists( application.accounts, arguments.accountId )>
			<cfreturn getBean( "setup" ).setAccount( AcctID = arguments.accountId ) />
		<cfelse>
			<cfreturn application.accounts[ arguments.accountId ] />
		</cfif>

    </cffunction>

	<cffunction name="getPolicy" access="remote" output="false" returntype="any" returnformat="json" hint="I retrieve a particular account policy">
		<cfargument name="policyId" type="numeric" required="true" />

		<cfif NOT( structKeyExists( application, "policies" ) AND structKeyExists( application.policies, arguments.policyId ) )>
			<cfset getBean( "Setup" ).setPolicy( arguments.policyId ) />
		</cfif>

		<!---TODO: Abstract this so that we're not reaching directly into the Application scope--->
		<cfreturn application.policies[ arguments.policyId ] />
	</cffunction>

    <cffunction name="getAccountPolicies" returntype="any" access="remote" output="false" returnformat="json" hint="">
        <cfargument name="accountId" type="numeric" required="true" />

        <cfreturn getBean( "AccountService" ).listAccountPolicies( arguments.accountId ) />

    </cffunction>

	<cffunction name="couldYou" access="remote" output="false" returntype="any" returnFormat="json" hint="I perform a CouldYou search for a particular search on the specified day">
		<cfargument name="searchId" type="numeric" required="true" />
		<cfargument name="requestedDate" type="date" required="true" />
		<cfargument name="requery" type="boolean" required="false" default="false" />

		<cfset var cy = structNew() />
		<cfset var cy.requestedDate = "#dateFormat( arguments.requestedDate, 'mm-dd-yyyy' )#" />
		<cfset var Search = getBean( "SearchService" ).load( arguments.searchId ) />
		<cfset cy.searchId = arguments.searchId />
		<cfset cy.searchStarted = now() />

		<cfif Search.getAir()>
			<cftry>
				<cfset cy.Air = getBean( 'AirPrice' ).doCouldYouSearch( Search, arguments.requestedDate, arguments.requery ) />
				<cfcatch type="any">
					<cfset cy.Air = "" />
				</cfcatch>
			</cftry>
		</cfif>

		<cfif Search.getHotel()>
			<cftry>
				<cfset cy.Hotel = getBean( 'HotelService' ).doCouldYouSearch( Search, arguments.requestedDate, arguments.requery ) />
				<cfcatch type="any">
					<cfset cy.Hotel = "" />
				</cfcatch>
			</cftry>
		</cfif>
		<cfif Search.getCar()>
			<cftry>
				<cfset cy.Car = getBean( 'Car' ).doCouldYouSearch( Search, arguments.requestedDate, arguments.requery ) />
				<cfcatch type="any">
					<cfset cy.Car = "" />
				</cfcatch>
			</cftry>
		</cfif>

		<cfset cy.searchEnded = now() />

		<!---Save the result of this call into the CouldYou logging table--->
		<cftry>
			<cfset getBean( "CouldYouService" ).logAlternateTrip( arguments.searchId, cy ) />

			<cfcatch type="any">
				<!---Log this error, but do not prevent the request from completing because we can't write the log entry--->
				<cfif getBean( 'EnvironmentService' ).getEnableBugLog()>
					 <cfset getBean('BugLogService').notifyService( message=cfcatch.Message, exception=cfcatch, severityCode='Error' ) />
				<cfelse>
					 <!--- <cfset super.onError( arguments.exception, arguments.eventName )> --->
				 </cfif>
			</cfcatch>
		</cftry>

		<cfreturn cy />

	</cffunction>

	<cffunction name="getSearchTraveler" access="remote" output="false" returntype="any" returnformat="json" hint="I retrieve a particular traveler that has been associated with a trip/search">
		<cfargument name="searchID" required="true" type="numeric">
		<cfargument name="travelerNumber" required="true" type="numeric">

		<cfreturn getBean("Summary").getTraveler( argumentCollection=arguments ) />

	</cffunction>

	<cffunction name="loadFindItGuest" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="searchID" type="numeric" required="true" />

		<cftry>
			<cfset local.findItGuest = getBean("findit").getFindItRequest(searchID = arguments.searchID) />

			<cfreturn findItGuest />

			<cfcatch type="any">
				<cfset logError(cfcatch, arguments) />
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="updateTravelerCompany" access="remote" output="false" returntype="any" returnformat="json" hint="I update a particular traveler whose company has been changed on the summary page and associated payments">
		<cfargument name="userID" required="true" type="numeric" />
		<cfargument name="acctID" required="true" type="numeric" />
		<cfargument name="arrangerID" required="true" type="numeric" />
		<cfargument name="searchID" required="true" type="numeric" />
		<cfargument name="travelerNumber" required="true" type="numeric" />
		<cfargument name="valueID" required="true" type="numeric" />
		<cfargument name="vendor" required="false" default="" />

		<cfset local.qOrgUnitValues = getBean("OrgUnitService").getOrgUnitValues(ouID = 399
																					, valueID = arguments.valueID
																					, returnFormat = "query") />

		<cfset session.searches[arguments.searchID].travelers[arguments.travelerNumber].getOrgUnit()[1].setValueID(qOrgUnitValues.Value_ID) />
		<cfset session.searches[arguments.searchID].travelers[arguments.travelerNumber].getOrgUnit()[1].setValueDisplay(qOrgUnitValues.Value_Display) />
		<cfset session.searches[arguments.searchID].travelers[arguments.travelerNumber].getOrgUnit()[1].setValueReport(qOrgUnitValues.Value_Report) />

		<cfset session.searches[arguments.searchID].travelers[arguments.travelerNumber].setPayment(getBean("PaymentService").getUserPayments(userID = arguments.userID
																					, acctID = arguments.acctID
																					, valueID = arguments.valueID
																					, arrangerID = arguments.arrangerID) )>

		<cfif arguments.vendor NEQ ''>
			<cfset session.searches[arguments.searchID].travelers[arguments.travelerNumber].addPayment(getBean("PaymentService").getCarPayments(userID = arguments.userID
																					, acctID = arguments.acctID
																					, valueID = arguments.valueID
																					, vendor = arguments.vendor) )>
		</cfif>

		<cfreturn session.searches[arguments.searchID].travelers[arguments.travelerNumber] />
	</cffunction>

	<cffunction name="getUAPILogEntries" access="remote" output="false" returntype="any" returnformat="plain" hint="I retrieve entries from the uAPI log based on the specified criteria">
		<cfargument name="searchID" type="numeric" required="false" />
		<cfargument name="acctId" type="numeric" required="false" />
		<cfargument name="userId" type="numeric" required="false" />
		<cfargument name="startDate" type="date" required="false" />
		<cfargument name="endDate" type="date" required="false" />
		<cfargument name="services" type="string" required="false" />

		<cfset var result = new com.shortstravel.RemoteResponse() />

		<cfif structKeyExists( arguments, "searchID" ) OR ( structKeyExists( arguments, "acctId" ) AND structKeyExists( arguments, "userId" ) )>
			<cfset var data = structNew() />

			<cftry>

				<cfset data[ 'entries' ] = getBean( "uAPI" ).getLogEntries( argumentCollection=arguments ) />

				<cfif structKeyExists( arguments, "searchId" )>
					<cfset data[ 'search' ] = getBean( "SearchService" ).load( arguments.searchId ) />
				</cfif>

				<cfset result.setData( data ) />

				<cfcatch type="any">
					<cfset result.addError( "An error occurred while retrieving log entries for the specified criteria." ) />
					<cfset result.setSuccess( false ) />
					<cfset logError( cfcatch, arguments ) />
				</cfcatch>
			</cftry>

		</cfif>

		<cfif structKeyExists( arguments, "callback" ) AND arguments.callback NEQ "">
			<cfcontent type="application/javascript" />
			<cfsavecontent variable="local.callbackFunction">
				<cfoutput>#arguments.callback#(#serializeJSON( result )#)</cfoutput>
			</cfsavecontent>
			<cfreturn callbackFunction />
		<cfelse>
			<cfreturn serializeJSON( result ) />
		</cfif>

	</cffunction>

	<cffunction name="getUAPILogEntry" access="remote" output="false" returntype="any" returnformat="plain" hint="">
		<cfargument name="entryId" type="numeric" required="false" />

		<cfset var result = new com.shortstravel.RemoteResponse() />
		<cfset result.setData( getBean( "uAPI" ).getLogEntry( argumentCollection=arguments ) )/>
		<cfif structKeyExists( arguments, "callback" ) AND arguments.callback NEQ "">
			<cfcontent type="application/javascript" />
			<cfsavecontent variable="local.callbackFunction">
				<cfoutput>#arguments.callback#(#serializeJSON( result )#)</cfoutput>
			</cfsavecontent>
			<cfreturn callbackFunction />
		<cfelse>
			<cfreturn serializeJSON( result ) />
		</cfif>

	</cffunction>

	<cffunction name="getBean" returntype="any" access="private" output="false" hint="I manage getting individual beans from ColdSpring">
		<cfargument name="beanName" type="string" required="true"/>

		<cfreturn application.fw.factory.getBean( arguments.beanName ) />
	</cffunction>

	<cffunction name="logError" returntype="any" access="private" output="false" hint="I send an error report to BugLogHQ">
		<cfargument name="Exception" required=true/>
		<cfargument name="ExtraInfo" type="any" required="false" default="" />

		<cfif application.fw.factory.getBean( 'EnvironmentService' ).getEnableBugLog() IS true>
			 <cfset application.fw.factory.getBean('BugLogService').notifyService( message=arguments.exception.Message, exception=arguments.exception, severityCode='Error', extraInfo=arguments.ExtraInfo ) />
		 </cfif>

	</cffunction>
</cfcomponent>