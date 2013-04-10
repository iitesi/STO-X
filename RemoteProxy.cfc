<cfcomponent name="STORemoteProxy" output="false">
	

	<cffunction name="getUser" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="userId" type="numeric" required="true"/>

		<cfreturn getBean( "UserService" ).load( arguments.userId ) />
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


	<cffunction name="getUserCCEmails" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="userId" type="numeric" required="true"/>
		<cfargument name="returnType" type="string" required="false" default="struct" hint="Valid values: query|array"/>

		<cfreturn getBean( "UserService" ).getUserCCEmails( arguments.userId, arguments.returnType ) />
	</cffunction>


	<cffunction name="getUserBARs" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="userId" type="numeric" required="true"/>
		<cfargument name="acctId" type="numeric" required="true"/>
		<cfargument name="returnCount" type="string" required="false" default="main" hint="Valid values: main|all"/>
		<cfargument name="returnType" type="string" required="false" default="query" hint="Valid values: query|array"/>

		<cfreturn getBean( "UserService" ).getUserBARs( arguments.userId, arguments.acctId, arguments.returnCount, arguments.returnType ) />
	</cffunction>


	<cffunction name="getUserFOPs" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="acctID" 		type="numeric" 	required="false" default="0" />
		<cfargument name="userID" 		type="numeric" 	required="false" default="0" />
		<cfargument name="valueID" 		type="numeric"	required="false" default="0" />
		<cfargument name="paymentTypes" type="string" 	required="false" default="all" 		hint="all, user, account, department" />
		<cfargument name="returnType"	type="string" 	required="false" default="array" 	hint="array, query" />

		<cfreturn getBean( "UserService" ).getUserFOPs( arguments.acctID, arguments.userID, arguments.valueID, arguments.paymentTypes, arguments.returnType ) />
	</cffunction>


	<cffunction name="getUserPAR" returntype="any" access="remote" output="false" hint="" returnformat="json">
		<cfargument name="userId" type="numeric" required="true"/>

		<cfreturn getBean( "UserService" ).getUserPAR( arguments.userId ) />
	</cffunction>


    <cffunction name="getSearch" returntype="any" access="remote" output="false" returnformat="json" hint="">
        <cfargument name="searchId" type="numeric" required="true"/>

        <cfreturn getBean( "SearchService" ).load( arguments.searchId ) />

    </cffunction>

    <cffunction name="getHotelSearchResults" returntype="any" access="remote" output="false" returnformat="json" hint="">
        <cfargument name="searchId" type="numeric" required="true"/>

        <cfreturn getBean( "HotelService" ).search( arguments.searchId ) />

    </cffunction>

	<cffunction name="getBean" returntype="any" access="private" output="false" hint="I manage getting individual beans from ColdSpring">
		<cfargument name="beanName" type="string" required="true"/>

		<cfreturn application.fw.factory.getBean( arguments.beanName ) />
	</cffunction>


</cfcomponent>