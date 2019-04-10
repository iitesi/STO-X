<cfcomponent output="false" accessors="true" extends="com.shortstravel.AbstractService">

	<cfproperty name="UnusedTicketService">

	<cffunction name="init" output="false" hint="Init method.">
		<cfargument name="UnusedTicketService">

		<cfset setUnusedTicketService(arguments.UnusedTicketService)>

		<cfreturn this>
	</cffunction>

	<cffunction name="getUser" output="false" hint="I get the user.">
		<cfargument name="userID" type="numeric" required="true">

		<cfquery name="local.qUser" datasource="Corporate_Production">
			SELECT First_Name
			, Last_Name
			, Email
			, Phone_Number
			FROM Users
			LEFT OUTER JOIN Biz_Contact_Info ON Users.User_ID = Biz_Contact_Info.User_ID
			WHERE Users.User_ID = <cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_integer" >
		</cfquery>

		<cfreturn qUser />
	</cffunction>

	<cffunction name="getTrip" output="false" hint="">
		<cfargument name="SearchID" type="numeric" required="true">
		<cfargument name="PropertyID" type="numeric" required="true">
		<cfquery name="local.getTrip" datasource="booking">
			SELECT TOP 1 ResultsJSON
			FROM FindItOptions_Hotel
			WHERE SearchID = <cfqueryparam value="#arguments.searchID#" cfsqltype="cf_sql_numeric" />
				AND PropertyID = <cfqueryparam value="#arguments.propertyID#" cfsqltype="cf_sql_varchar" />
			ORDER BY ID DESC
		</cfquery>
		<cfreturn getTrip />
	</cffunction>

	<cffunction name="getUnusedTickets">
		<cfargument name="ProfileId" required="true">

		<cfset local.unusedTicketStruct = {}>
		<cfif arguments.ProfileID NEQ 0>

			<cfset local.UnusedTickets = UnusedTicketService.getUnusedTickets( userID = arguments.ProfileID ) />

			<cfloop array="#local.UnusedTickets#" index="local.unusedTicketIndex" item="local.unusedTicketItem">
				<cfif NOT structKeyExists(local.unusedTicketStruct, local.unusedTicketItem.getCarrier())>
					<cfset local.unusedTicketStruct[ local.unusedTicketItem.getCarrier() ] = ''>
					<cfloop array="#local.UnusedTickets#" index="local.subUnusedTicketIndex" item="local.subUnusedTicketItem">
						<cfif local.unusedTicketItem.getCarrier() EQ local.subUnusedTicketItem.getCarrier()>
							<cfset local.unusedTicketStruct[ local.unusedTicketItem.getCarrier() ] = local.unusedTicketStruct[ local.unusedTicketItem.getCarrier() ]&'
																										Airline:  #local.subUnusedTicketItem.getCarrierName()#<br>
																										Ticket Number:  #local.subUnusedTicketItem.getTicketNumber()#<br>
																										Credit:  #dollarFormat(local.subUnusedTicketItem.getAirfare())#<br>
																										Expiration:  #dateFormat(local.subUnusedTicketItem.getExpirationDate(), 'm/d/yyyy')#<br>
																										Original Ticket Issued to:  #local.subUnusedTicketItem.getLastName()#/#local.subUnusedTicketItem.getFirstName()#<br><br>'>
																									</tr>">
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>
			<cfset local.unusedTicketStruct>
		<cfelse>
			<cfset local.unusedTicketStruct = [] />
		</cfif>

		<cfreturn local.unusedTicketStruct />
	</cffunction>

</cfcomponent>