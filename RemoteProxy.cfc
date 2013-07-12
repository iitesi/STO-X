<cfcomponent name="STORemoteProxy" output="false">


	<cffunction name="getAuthorizedTravelers" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="userID" type="numeric" required="true"/>
		<cfargument name="acctID" type="numeric" required="true"/>
		<cfargument name="returnFormat" type="string" required="false" default="array"/>

		<cfreturn getBean( "UserService" ).getAuthorizedTravelers( argumentCollection=arguments ) />
	</cffunction>
	

	<cffunction name="getUser" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="userId" type="numeric" required="true"/>

		<cfreturn getBean( "UserService" ).load( arguments.userId ) />
	</cffunction>
	

	<cffunction name="loadFullUser" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="userID" type="numeric" required="true"/>
		<cfargument name="acctID" type="numeric" required="true"/>

		<cfset local.Traveler = getBean( "UserService" ).loadFullUser( userID = arguments.userId, acctID = arguments.acctID )>
		<cfset local.BookingDetail = createObject('component', 'booking.model.BookingDetail').init()>
		<cfset Traveler.setBookingDetail( BookingDetail )>

		<cfreturn Traveler />
	</cffunction>
	

	<cffunction name="loadOrgUnit" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="acctID" type="numeric" required="true">
		<cfargument name="valueID" type="numeric" required="true">
		<cfargument name="userID" type="numeric" required="true">

		<cfreturn getBean( "OrgUnitService" ).loadOrgUnit( acctID = arguments.acctID, valueID = arguments.valueID, userID = arguments.userID ) />
	</cffunction>


	<cffunction name="getOrgUnitValues" returntype="any" access="remote" output="false" returnformat="JSON">
		<cfargument name="ouID" required="true">
		<cfargument name="conditionalSort1" required="false" default="">
		<cfargument name="conditionalSort2" required="false" default="">
		<cfargument name="conditionalSort3" required="false" default="">
		<cfargument name="conditionalSort4" required="false" default="">
		<cfargument name="conditionalSort5" required="false" default="">
		<cfargument name="returnFormat" type="string" required="false" default="array"/>

		<cfset local.qOrgUnitValues = getBean( "OrgUnitService" ).getOrgUnitValues( ouID = arguments.ouID
																			, conditionalSort1 = arguments.conditionalSort1
																			, conditionalSort2 = arguments.conditionalSort2
																			, conditionalSort3 = arguments.conditionalSort3
																			, conditionalSort4 = arguments.conditionalSort4
																			, conditionalSort5 = arguments.conditionalSort5
																			, returnFormat = arguments.returnFormat ) />

		<cfreturn serializeJSON( qOrgUnitValues ) />
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
			</cfcatch>

		</cftry>

        <cfreturn result />

	</cffunction>

    <cffunction name="getHotelSearchResults" returntype="any" access="remote" output="false" returnformat="json" hint="">
        <cfargument name="searchId" type="numeric" required="true"/>
		<cfargument name="requery" type="boolean" required="false" default="false" />

        <cfreturn getBean( "HotelService" ).search( argumentCollection=arguments ) />

    </cffunction>

    <cffunction name="getAvailableHotelRooms" returntype="any" access="remote" returnformat="json" output="false" hint="">
        <cfargument name="searchId" type="numeric" required="true"/>
        <cfargument name="propertyId" type="numeric" required="true" />
        <cfargument name="requery" type="boolean" required="false" default="false" />

        <cfreturn getBean( "HotelService" ).getAvailableRooms( argumentCollection=arguments ) />

    </cffunction>

	<cffunction name="getHotelDetails" access="remote" output="false" returntype="any" returnformat="json" hint="I get the extended details for a particular hotel">
		<cfargument name="propertyId" type="numeric" requred="true" />
		<cfargument name="forceUpdate" type="boolean" required="false" default="false" />

		<cfset var result = new com.shortstravel.RemoteResponse() />

		<!---<cftry>--->
			<cfset result.setData( getBean( "HotelService" ).getExtendedHotelData( argumentCollection=arguments ) ) />

			<!---<cfcatch type="any">
				<cfset result.addError( "An error occurred while retrieving extended data for the requested hotel." ) />
				<cfset result.setSuccess( false ) />
			</cfcatch>
		</cftry>--->

		<cfreturn result />

	</cffunction>

	<cffunction name="selectHotelRoom" access="remote" output="false" returntype="any" returnformat="json" hint="">
		<cfargument name="searchId" type="numeric" required="true" />
		<cfargument name="propertyId" type="numeric" required="true" />
		<cfargument name="ratePlanType" type="string" required="true" />
		<cfargument name="totalForStay" type="numeric" required="true" />

		<cfset var result = new com.shortstravel.RemoteResponse() />

		<cftry>

			<cfset result.setSuccess( getBean( "HotelService" ).selectRoom( argumentCollection = arguments ) ) />

			<cfcatch type="any">
				<cfset result.addError( "An error occurred while attempting to record your room selection." ) />
				<cfset result.setSuccess( false ) />
			</cfcatch>

		</cftry>

		<cfreturn result />

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

	<cffunction name="getBean" returntype="any" access="private" output="false" hint="I manage getting individual beans from ColdSpring">
		<cfargument name="beanName" type="string" required="true"/>

		<cfreturn application.fw.factory.getBean( arguments.beanName ) />
	</cffunction>


</cfcomponent>