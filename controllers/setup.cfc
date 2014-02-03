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
		<cfif NOT StructKeyExists(application, 'searchWidgetURL') OR application.searchWidgetURL EQ ''>
			<cfset variables.bf.getBean("setup").setWidgetURL(argumentcollection=arguments.rc)>
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
		<cfif NOT StructKeyExists(application, 'sCityCodes') OR application.sCityCodes EQ ''>
			<cfset variables.bf.getBean("setup").setCityCodes()>
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
		<cfif NOT StructKeyExists(application, 'blackListedCarrierPairing')>
			<cfset variables.bf.getBean("setup").setBlackListedCarrierPairing(argumentcollection=arguments.rc)>
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
		<cfif StructKeyExists(session, 'Filters')
			AND StructKeyExists(session.Filters, arguments.rc.SearchID)
			AND NOT StructKeyExists(arguments.rc, "requery")>
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

	<cffunction name="setTMC" access="public" output="false" returntype="any" hint="">
		<cfargument name="rc" type="struct" required="true" />

		<cfif StructKeyExists(application, 'Accounts')
			AND StructKeyExists(application.Accounts, arguments.rc.AcctID)
			AND isStruct( application.Accounts[ arguments.rc.AcctId ] )
			AND (NOT structKeyExists( application.Accounts[ arguments.rc.AcctId ], "tmc" )
				OR NOT structKeyExists( application.Accounts[ arguments.rc.AcctId ].tmc, "ShortName"))>

			<cfset application.Accounts[ arguments.rc.AcctId ].tmc = variables.bf.getBean( "AccountService" ).getAccountTMC( application.Accounts[ arguments.rc.AcctId ].AccountBrand ) />
			<cfset rc.Account = application.Accounts[arguments.rc.AcctID]>

			<cfif NOT structKeyExists( session, "TMC" )>
				<cfset session.tmc = application.Accounts[ arguments.rc.AcctId].tmc />
			</cfif>
		</cfif>

		<cfreturn />

	</cffunction>

	<cffunction name="setPolicyID" output="false">
		<cfset rc.PolicyID = (structKeyExists(session, 'PolicyID') ? session.PolicyID : 0)>
		<cfreturn />
	</cffunction>

	<cffunction name="setPolicy" output="false">
		<cfargument name="rc">

		<!--- doublecheck the policyID is set --->
		<cfif NOT structKeyExists(rc, "policyID")>
			<cfset rc.policyID = arguments.rc.filter.getPolicyID()>
		</cfif>

		<!---	Move the Policy into the rc scope so it is always available.
					Lazy loading, adds policies to the application scope as needed.--->
		<cfif StructKeyExists(application, 'Policies')
			AND structKeyExists(arguments.rc, 'PolicyID')
			AND StructKeyExists(application.Policies, rc.PolicyID)>
			<cfset rc.Policy = application.Policies[rc.PolicyID]>
		<cfelse>
			<cfset rc.Policy = variables.bf.getBean("setup").setPolicy( argumentcollection=arguments.rc )>
		</cfif>

		<cfreturn />
	</cffunction>

	<cffunction name="setGroup" output="false">
		<cfargument name="rc">

		<cfset rc.Group = (StructKeyExists(request.context, 'Group') ? request.context.Group : '')>

		<cfreturn />
	</cffunction>
</cfcomponent>