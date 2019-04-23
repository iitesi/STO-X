<cfcomponent output="false" accessors="true" extends="com.shortstravel.AbstractService">

	<cfproperty name="UAPIFactory">
	<cfproperty name="uAPISchemas">
	<cfproperty name="AirParse">
	<cfproperty name="KrakenService">

	<cffunction name="init" output="false" hint="Init method.">
		<cfargument name="UAPIFactory">
		<cfargument name="uAPISchemas">
		<cfargument name="AirParse">
		<cfargument name="KrakenService">

		<cfset setUAPIFactory(arguments.UAPIFactory)>
		<cfset setUAPISchemas(arguments.uAPISchemas)>
		<cfset setAirParse(arguments.AirParse)>
		<cfset setKrakenService(arguments.KrakenService)>

		<cfreturn this>
	</cffunction>

	<cffunction name="createLowFareAvail" output="false">
		<cfargument name="stTrips" required="true">
		<cfargument name="stAvailTrips" required="true">
		<cfargument name="Group" required="true">

		<cfset local.stLowFareAvail = createstLowFareAvail(stTrips = arguments.stTrips, stAvailTrips = arguments.stAvailTrips, Group = arguments.Group)>

		<cfreturn local.stLowFareAvail/>
	</cffunction>

	<cffunction name="createstLowFareAvail" output="false">
		<cfargument name="stTrips" required="true">
		<cfargument name="stAvailTrips" required="true">
		<cfargument name="Group" required="true">

		<cfset local.stLowFareAvail = structNew()>

		<!--- Create a new structure that is a link between stTrips and stAvailTrips with a common key and all price information --->
		<cfloop collection="#arguments.stTrips#" index="local.tripIndex" item="local.tripItem">
			<cfloop collection="#local.tripItem.Groups#" index="local.groupIndex" item="local.groupItem">
				<cfif NOT structKeyExists(local.stLowFareAvail, local.groupIndex)
					OR NOT structKeyExists(local.stLowFareAvail[local.groupIndex], local.groupItem.tripID)
					OR NOT structKeyExists(local.stLowFareAvail[local.groupIndex][local.groupItem.tripID], local.tripItem.cabinClass)
					OR NOT local.stLowFareAvail[local.groupIndex][local.groupItem.tripID][local.tripItem.cabinClass].Total GT local.tripItem.Total>
					<cfset local.stLowFareAvail[local.groupIndex][local.groupItem.tripID][local.tripItem.cabinClass].stTrips = local.tripIndex>
					<cfset local.stLowFareAvail[local.groupIndex][local.groupItem.tripID][local.tripItem.cabinClass].Base = local.tripItem.Base>
					<cfset local.stLowFareAvail[local.groupIndex][local.groupItem.tripID][local.tripItem.cabinClass].ApproximateBase = local.tripItem.ApproximateBase>
					<cfset local.stLowFareAvail[local.groupIndex][local.groupItem.tripID][local.tripItem.cabinClass].Taxes = local.tripItem.Taxes>
					<cfset local.stLowFareAvail[local.groupIndex][local.groupItem.tripID][local.tripItem.cabinClass].Total = local.tripItem.Total>
					<cfset local.stLowFareAvail[local.groupIndex][local.groupItem.tripID][local.tripItem.cabinClass].CabinClass = local.tripItem.CabinClass>
					<cfset local.stLowFareAvail[local.groupIndex][local.groupItem.tripID][local.tripItem.cabinClass].PrivateFare = local.tripItem.PrivateFare>
					<cfset local.stLowFareAvail[local.groupIndex][local.groupItem.tripID][local.tripItem.cabinClass].ChangePenalty = local.tripItem.ChangePenalty>
					<cfset local.stLowFareAvail[local.groupIndex][local.groupItem.tripID][local.tripItem.cabinClass].PTC = local.tripItem.PTC>
					<cfset local.stLowFareAvail[local.groupIndex][local.groupItem.tripID][local.tripItem.cabinClass].Ref = local.tripItem.Ref>
					<cfset local.stLowFareAvail[local.groupIndex][local.groupItem.tripID][local.tripItem.cabinClass].TotalBag = local.tripItem.TotalBag>
					<cfset local.stLowFareAvail[local.groupIndex][local.groupItem.tripID][local.tripItem.cabinClass].TotalBag2 = local.tripItem.TotalBag2>
					<cfset local.stLowFareAvail[local.groupIndex][local.groupItem.tripID][local.tripItem.cabinClass].Policy = local.tripItem.Policy>
					<cfset local.stLowFareAvail[local.groupIndex][local.groupItem.tripID][local.tripItem.cabinClass].aPolicies = local.tripItem.aPolicies>
				</cfif>
			</cfloop>
		</cfloop>

		<cfloop collection="#arguments.stAvailTrips#" index="local.overallGroupIndex" item="local.overallGroupItem">
			<cfloop collection="#local.overallGroupItem#" index="local.tripIndex" item="local.tripItem">
				<cfloop collection="#local.tripItem.Groups#" index="local.groupIndex" item="local.groupItem">
					<cfset local.stLowFareAvail[local.overallGroupIndex][local.groupItem.tripID].stAvailTrips = local.tripIndex>
				</cfloop>
			</cfloop>
		</cfloop>

		<cfreturn local.stLowFareAvail/>
	</cffunction>

</cfcomponent>
