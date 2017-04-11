<cfcomponent extends="abstract" output="false">

<!---
setApplication
--->
	<cffunction name="setApplication" output="false" returntype="void">

		<cfset application.Accounts = structNew() />

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
		<cfif NOT StructKeyExists(application, 'stKTPrograms') OR StructIsEmpty(application.stKTPrograms)>
			<cfset variables.bf.getBean("setup").setKTPrograms(argumentcollection=arguments.rc)>
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
		<cfif NOT StructKeyExists(application, 'staticAssetVersion')>
			<cfset application.staticAssetVersion = variables.bf.getBean("EnvironmentService").getStaticAssetVersion()>
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
		<cfargument name="rc"/>
		<cfset rc.acctId = (structKeyExists(session,"acctId") ? session.acctId : 0)/>
		<cfif rc.acctId EQ 0 AND structKeyExists(cookie,"acctId")>
			<cfset rc.acctId = val(cookie.acctId)/>
		</cfif>
		<cfreturn/>
	</cffunction>

	<cffunction name="setAccountIds" output="false">
		<cfquery name="local.getReportToIDs" datasource="corporate_production">
			SELECT LTrim(RTrim(ReportToID)) AS ReportToID
			  FROM Accounts_ReportToIDs, Accounts
			 WHERE Accounts_ReportToIDs.Acct_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.acctid#"/>
			   AND Accounts.Acct_ID = Accounts_ReportToIDs.Acct_ID
			   AND ReportToID != ''
			   AND ReportToID IS NOT NULL
		</cfquery>
		<cfif getReportToIDs.RecordCount GT 0>
			<cfset session.accountIds = valueList(getReportToIDs.ReportToID)/>
		<cfelse>
			<cfset session.accountIds = 0/>
		</cfif>
	</cffunction>

	<cffunction name="setAccount" output="false">
		<cfargument name="rc">

		<!---Move the Account into the rc scope so it is always available.--->
		<cfif StructKeyExists(application, 'Accounts')
			AND StructKeyExists(application.Accounts, arguments.rc.AcctID)
			AND dateDiff( 'n', application.Accounts[ arguments.rc.AcctID ].loadTime, now() ) LT 1>
			<cfset rc.Account = application.Accounts[arguments.rc.AcctID]>
		<!---Lazy loading, adds account to the application scope as needed.--->
		<cfelseif arguments.rc.AcctID GT 0>
			<cfset application.Accounts[arguments.rc.AcctID] = variables.bf.getBean("setup").setAccount(argumentcollection=arguments.rc) />
			<cfset application.Accounts[arguments.rc.AcctID].TMC = variables.bf.getBean( "AccountService" ).getAccountTMC(application.Accounts[arguments.rc.AcctID].AccountBrand) />
			<cfset session.TMC = application.Accounts[arguments.rc.AcctID].TMC />
			<cfset rc.Account = application.Accounts[arguments.rc.AcctID]>
		</cfif>

		<cfreturn />
	</cffunction>

	<cffunction name="setTMC" output="false">
		<cfargument name="rc">

		<!---Move the Account into the rc scope so it is always available.--->
		<cfif NOT StructKeyExists(session, 'TMC') OR NOT isobject(session.TMC )>
			<cfset session.TMC = application.Accounts[arguments.rc.AcctID].TMC />
		</cfif>

		<cfreturn />
	</cffunction>

	<cffunction name="setInvoiceTableSuffix" output="false">
		<cfquery name="local.getTableName" datasource="corporate_production">
			SELECT Table_Name
			  FROM Accounts
			 WHERE Acct_ID = <cfqueryparam value="#session.acctId#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfset session.InvoiceTableSuffix = local.getTableName.Table_Name>
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

		<!---not using cached version STM-6824
		<cfif StructKeyExists(application, 'Policies')
			AND structKeyExists(arguments.rc, 'PolicyID')
			AND StructKeyExists(application.Policies, rc.PolicyID)>
			<cfset rc.Policy = application.Policies[rc.PolicyID]>
		<cfelse>
			<cfset rc.Policy = variables.bf.getBean("setup").setPolicy( argumentcollection=arguments.rc )>
		</cfif>--->

		<cfset rc.Policy = variables.bf.getBean("setup").setPolicy( argumentcollection=arguments.rc )>

		<cfreturn />
	</cffunction>

	<cffunction name="resetPolicy" output="false">
		<cfargument name="rc">
		<cfparam name="rc.debugPolicy" value="false" />
		<!--- doublecheck the policyID is set --->
		<cfif NOT structKeyExists(rc, "policyID")>
			<cfset rc.policyID = arguments.rc.filter.getPolicyID()>
		</cfif>
		<cfset rc.Policy = variables.bf.getBean("setup").setPolicy( argumentcollection=arguments.rc )>
		<cfset variables.fw.setView('main.policy')/>
	</cffunction>

	<cffunction name="setGroup" output="false">
		<cfargument name="rc">

		<cfset rc.Group = (StructKeyExists(request.context, 'Group') ? request.context.Group : '')>

		<cfreturn />
	</cffunction>

	<cffunction name="setBlackListedCarrierPairing" output="false">
		<cfargument name="rc">
		<cfif NOT StructKeyExists(application, 'blackListedCarrierPairing')>
			<cfset variables.bf.getBean("setup").setBlackListedCarrierPairing(argumentcollection=arguments.rc)>
		</cfif>
		<cfreturn />
	</cffunction>
</cfcomponent>
