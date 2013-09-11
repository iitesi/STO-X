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

	<cffunction name="getCarPayments" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="acctID" type="numeric" required="true"/>
		<cfargument name="userID" type="numeric" required="true"/>
		<cfargument name="valueID" type="numeric" required="false" default="0"/>
		<cfargument name="vendor" type="string" required="false" default=""/>

		<cfreturn getBean( "PaymentService" ).getCarPayments( acctID = arguments.acctID, userID = arguments.userID, valueID = arguments.valueID, vendor = arguments.vendor ) />
	</cffunction>

	<cffunction name="getUserPayments" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="userId" type="numeric" required="true"/>
		<cfargument name="arrangerID" required="false" default=""/>
		<cfargument name="acctID" type="numeric" required="true"/>
		<cfargument name="returnType" type="string" required="false" default="struct" hint="Valid values: query|array|string"/>

		<cfreturn getBean( "PaymentService" ).getUserPayments( acctID = arguments.acctID, userID = arguments.userID, arrangerID = arguments.arrangerID, valueID = arguments.valueID ) />
	</cffunction>

	<cffunction name="getUserFOPs" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="acctID" 		type="numeric" 	required="false" default="0" />
		<cfargument name="userID" 		type="numeric" 	required="false" default="0" />
		<cfargument name="valueID" 		type="numeric"	required="false" default="0" />
		<cfargument name="paymentTypes" type="string" 	required="false" default="all" 		hint="all, user, account, department" />
		<cfargument name="returnType"	type="string" 	required="false" default="array" 	hint="array, query" />

		<cfreturn getBean( "UserService" ).getUserFOPs( arguments.acctID, arguments.userID, arguments.valueID, arguments.paymentTypes, arguments.returnType ) />
	</cffunction>

	<cffunction name="getUserDepartment" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="userID" type="numeric" required="true"/>
		<cfargument name="acctID" type="numeric" required="true"/>

		<cfreturn getBean( "UserService" ).getUserDepartment( arguments.userId, arguments.acctId ) />
	</cffunction>

	<cffunction name="getUserFFAccounts" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="userId" type="numeric" required="true"/>
		<cfargument name="custType" type="string" required="false" default=""/>
		<cfargument name="returnType" type="string" required="false" default="struct" hint="Valid values: query|struct"/>

		<cfreturn getBean( "UserService" ).getUserFFAccounts( arguments.userId, arguments.custType, arguments.returnType ) />
	</cffunction>

	<cffunction name="getUserBARs" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="userId" type="numeric" required="true"/>
		<cfargument name="acctId" type="numeric" required="true"/>
		<cfargument name="returnCount" type="string" required="false" default="main" hint="Valid values: main|all"/>
		<cfargument name="returnType" type="string" required="false" default="query" hint="Valid values: query|array"/>

		<cfreturn getBean( "UserService" ).getUserBARs( arguments.userId, arguments.acctId, arguments.returnCount, arguments.returnType ) />
	</cffunction>

	<cffunction name="getUserPAR" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="userId" type="numeric" required="true"/>

		<cfreturn getBean( "UserService" ).getUserPAR( arguments.userId ) />
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
		<cfargument name="requery" type="boolean" required="false" default="false" />

        <cfreturn getBean( "HotelService" ).search( argumentCollection=arguments ) />

    </cffunction>

    <cffunction name="getAvailableHotelRooms" returntype="any" access="remote" returnformat="plain" output="false" hint="">
        <cfargument name="searchId" type="numeric" required="true"/>
        <cfargument name="propertyId" type="numeric" required="true" />
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
		<cfargument name="propertyId" type="numeric" requred="true" />
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
		<cfset var cy.requestedDate = arguments.requestedDate />
		<cfset var Search = getBean( "SearchService" ).load( arguments.searchId ) />

		<cfif Search.getAir()>
			<cfset cy.Air = getBean( 'AirPrice' ).doCouldYouSearch( Search, arguments.requestedDate, arguments.requery ) />
		</cfif>

		<cfif Search.getHotel()>
			<cfset cy.Hotel = getBean( 'HotelService' ).doCouldYouSearch( Search, arguments.requestedDate, arguments.requery ) />
		</cfif>
		<cfif Search.getCar()>
			<cfset cy.Car = getBean( 'Car' ).doCouldYouSearch( Search, arguments.requestedDate, arguments.requery ) />
		</cfif>

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
	
	<cffunction name="getBean" returntype="any" access="private" output="false" hint="I manage getting individual beans from ColdSpring">
		<cfargument name="beanName" type="string" required="true"/>

		<cfreturn application.fw.factory.getBean( arguments.beanName ) />
	</cffunction>

	<cffunction name="logError" returntype="any" access="private" output="false" hint="I send an error report to BugLogHQ">
		<cfargument name="Exception" required=true/>
		<cfargument name="ExtraInfo" type="any" required="false" default="" />

		<cfif application.fw.factory.getBean( 'EnvironmentService' ).getEnableBugLog() IS true>
			 <cfset application.fw.factory.getBean('BugLogService').notifyService( message=arguments.exception.Message, exception=arguments.exception, severityCode='Fatal', extraInfo=arguments.ExtraInfo ) />
		 </cfif>

	</cffunction>
</cfcomponent>