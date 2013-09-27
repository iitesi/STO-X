<cfcomponent output="false" accessors="true">

	<cfproperty name="bookingDSN"/>

	<cffunction name="init" output="false">
		<cfargument name="bookingDSN" type="string" requred="true" />

		<cfset setBookingDSN( arguments.bookingDSN ) />

		<cfreturn this>
	</cffunction>

	<cffunction name="databaseInvoices" output="false" hint="I get the user.">
		<cfargument name="Travelers" type="numeric" required="true">

		<cfloop array="#arguments.Travelers#" index="local.travelerIndex" item="local.Traveler">
			<cfdump var="#Traveler#" />
		</cfloop>
		<!--- <cfquery name="local.qUser" datasource="#getBookingDSN()#">
			SELECT First_Name
			, Last_Name
			, Email
			, Phone_Number
			FROM Users
			LEFT OUTER JOIN Biz_Contact_Info ON Users.User_ID = Biz_Contact_Info.User_ID
			WHERE Users.User_ID = <cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_integer" >
		</cfquery> --->
<cfabort />
		<cfreturn />
	</cffunction>

</cfcomponent>