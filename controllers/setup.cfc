<cfcomponent extends="abstract" output="false">

<!---
setApplication
--->
	<cffunction name="setApplication" output="false" returntype="void">

		<cfif NOT StructKeyExists(application, 'sServerURL') OR application.sServerURL EQ ''>
			<cfset variables.bf.getBean("setup").setServerURL(argumentcollection=arguments.rc)>
		</cfif>
		<cfif NOT StructKeyExists(application, 'sPortalURL') OR application.sPortalURL EQ ''>
			<cfset variables.bf.getBean("setup").setPortalURLLink(argumentcollection=arguments.rc)>
		</cfif>
		<cfif NOT StructKeyExists(application, 'sAPIAuth') OR application.sAPIAuth EQ ''>
			<cfset variables.bf.getBean("setup").setAPIAuth(argumentcollection=arguments.rc)>
		</cfif>
		<cfif NOT StructKeyExists(application, 'stAirVendors') OR StructIsEmpty(application.stAirVendors)>
			<cfset variables.bf.getBean("setup").setAirVendors(argumentcollection=arguments.rc)>
		</cfif>
		<cfif NOT StructKeyExists(application, 'stCarVendors') OR StructIsEmpty(application.stCarVendors)>
			<cfset variables.bf.getBean("setup").setCarVendors(argumentcollection=arguments.rc)>
		</cfif>
		<cfif NOT StructKeyExists(application, 'stHotelVendors') OR StructIsEmpty(application.stHotelVendors)>
			<cfset variables.bf.getBean("setup").setHotelVendors(argumentcollection=arguments.rc)>
		</cfif>
		<cfif NOT StructKeyExists(application, 'stEquipment') OR StructIsEmpty(application.stEquipment)>
			<cfset variables.bf.getBean("setup").setEquipment(argumentcollection=arguments.rc)>
		</cfif>
		<cfif NOT StructKeyExists(application, 'stAirports') OR StructIsEmpty(application.stAirports)>
			<cfset variables.bf.getBean("setup").setAirports(argumentcollection=arguments.rc)>
		</cfif>
		<cfif NOT StructKeyExists(application, 'stAmenities') OR StructIsEmpty(application.stAmenities)>
			<cfset variables.bf.getBean("setup").setAmenities(argumentcollection=arguments.rc)>
		</cfif>
		<cfif NOT StructKeyExists(application, 'stStates') OR StructIsEmpty(application.stStates)>
			<cfset variables.bf.getBean("setup").setStates(argumentcollection=arguments.rc)>
		</cfif>
		<cfif NOT StructKeyExists(application, 'assetURL')>
			<cfset application.assetURL = variables.bf.getBean("EnvironmentService").getAssetURL()>
		</cfif>
		<cfif NOT StructKeyExists(application, 'blacklistedCarriers')>
			<cfset variables.bf.getBean("setup").setBlackListedCarrier(argumentcollection=arguments.rc)>
		</cfif>

		<cfreturn />
	</cffunction>

	<cffunction name="setSearchID" output="false" hint="I set the search ID.">
		<cfargument name="rc">
		<cfset rc.SearchID = (StructKeyExists(arguments.rc, 'SearchID') ? arguments.rc.SearchID : 0)>
		<cfreturn />
	</cffunction>

	<cffunction name="setFilter" output="false" hint="Move the search into the rc scope so it is always available.">
		<cfargument name="rc">
		<cfif StructKeyExists(session, 'Filters') AND StructKeyExists(session.Filters, arguments.rc.SearchID) AND NOT StructKeyExists(arguments.rc, "requery")>
			<cfset rc.Filter = session.Filters[arguments.rc.SearchID]>
		<cfelse>
			<cfset rc.Filter = variables.fw.getBeanFactory().getBean("setup").setFilter(argumentcollection=arguments.rc)>
		</cfif>
		<cfreturn />
	</cffunction>

	<cffunction name="setAcctID" output="false">
		<cfargument name="rc">

		<cfset rc.AcctID = (structKeyExists(session, 'AcctID') ? session.AcctID : 0)>

		<cfreturn />
	</cffunction>

	<cffunction name="setAccount" output="false">
		<cfargument name="rc">

		<!---Move the Account into the rc scope so it is always available.--->
		<cfif StructKeyExists(application, 'Accounts') AND StructKeyExists(application.Accounts, arguments.rc.AcctID)>
			<cfset rc.Account = application.Accounts[arguments.rc.AcctID]>
		<!---Lazy loading, adds account to the application scope as needed.--->
		<cfelse>
			<cfset rc.Account = variables.bf.getBean("setup").setAccount(argumentcollection=arguments.rc)>
		</cfif>

		<cfreturn />
	</cffunction>

	<cffunction name="setPolicyID" output="true">
		<cfargument name="rc">

		<cfset rc.PolicyID = (structKeyExists(session, 'PolicyID') ? session.PolicyID : 0)>

		<cfreturn />
	</cffunction>

	<cffunction name="setPolicy" output="true">
		<cfargument name="rc">

		<!---Move the Policy into the rc scope so it is always available.--->
		<cfif StructKeyExists(application, 'Policies') AND StructKeyExists(application.Policies, rc.PolicyID)>
			<cfset rc.Policy = application.Policies[rc.PolicyID]>
		<!---Lazy loading, adds policies to the application scope as needed.--->
		<cfelse>
			<cfset rc.Policy = variables.bf.getBean("setup").setPolicy(argumentcollection=arguments.rc)>
		</cfif>

		<cfreturn />
	</cffunction>

	<cffunction name="setGroup" output="false">
		<cfargument name="rc">

		<cfset rc.Group = (StructKeyExists(request.context, 'Group') ? request.context.Group : '')>

		<cfreturn />
	</cffunction>

	<cffunction name="setBlackListedCarrierPairing" output="false" hint="I return a list of carriers that cannot be booked on the same ticket together.">

		<cfset rc.BlackListedCarrierPairing = variables.bf.getBean("setup").setBlackListedCarrierPairing()>

		<cfreturn />
	</cffunction>

</cfcomponent>