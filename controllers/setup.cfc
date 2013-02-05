<cfcomponent output="false">

	<cfset variables.fw = "">
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="fw">

		<cfset variables.fw = arguments.fw>
        <cfset variables.bf = fw.getBeanFactory()>

		<cfreturn this>
	</cffunction>

<!--- setup : setApplication --->
	<cffunction name="setApplication" output="false" returntype="void">
		
		<cfif NOT StructKeyExists(application, 'sServerURL') OR application.sServerURL EQ ''>
			<cfset variables.fw.service('setup.setServerURL', 'void')>
		</cfif>
		<cfif NOT StructKeyExists(application, 'sPortalURL') OR application.sPortalURL EQ ''>
			<cfset variables.fw.service('setup.setPortalURL', 'void')>
		</cfif>
		<cfif NOT StructKeyExists(application, 'sAPIAuth') OR application.sAPIAuth EQ ''>
			<cfset variables.fw.service('setup.setAPIAuth', 'void')>
		</cfif>
		<cfif NOT StructKeyExists(application, 'stAirVendors') OR StructIsEmpty(application.stAirVendors)>
			<cfset variables.fw.service('setup.setAirVendors', 'void')>
		</cfif>
		<cfif NOT StructKeyExists(application, 'stCarVendors') OR StructIsEmpty(application.stCarVendors)>
			<cfset variables.fw.service('setup.setCarVendors', 'void')>
		</cfif>
		<cfif NOT StructKeyExists(application, 'stHotelVendors') OR StructIsEmpty(application.stHotelVendors)>
			<cfset variables.fw.service('setup.setHotelVendors', 'void')>
		</cfif>
		<cfif NOT StructKeyExists(application, 'stEquipment') OR StructIsEmpty(application.stEquipment)>
			<cfset variables.fw.service('setup.setEquipment', 'void')>
		</cfif>
		<cfif NOT StructKeyExists(application, 'stAirports') OR StructIsEmpty(application.stAirports)>
			<cfset variables.fw.service('setup.setAirports', 'void')>
		</cfif>
		<cfif NOT StructKeyExists(application, 'stAmenities') OR StructIsEmpty(application.stAmenities)>
			<cfset variables.fw.service('setup.setAmenities', 'void')>
		</cfif>
		<cfif NOT StructKeyExists(application, 'hotelphotos')>
			<cfset application.hotelphotos = CreateObject('component','booking.services.hotelphotos') />
		</cfif>
		
		<cfreturn />
	</cffunction>

<!---
setSearchID
--->
	<cffunction name="setSearchID" output="false">
		<cfargument name="rc">

		<cfset rc.SearchID = (StructKeyExists(arguments.rc, 'SearchID') ? arguments.rc.SearchID : 0)>

		<cfreturn />
	</cffunction>

<!---
setFilter
--->
	<cffunction name="setFilter" output="false">
		<cfargument name="rc">

		<!---Move the search into the rc scope so it is always available.--->
		<cfif StructKeyExists(session, 'Filters') AND StructKeyExists(session.Filters, arguments.rc.SearchID)>
			<cfset rc.Filter = session.Filters[arguments.rc.SearchID]>
		<!---Add search to the session scope.--->
		<cfelse>
			<cfset rc.Filter = variables.bf.getBean("setup").setFilter(argumentcollection=arguments.rc)>
		</cfif>

		<cfreturn />
	</cffunction>

<!---
setAcctID
--->
	<cffunction name="setAcctID" output="false">
		<cfargument name="rc">

		<cfset rc.AcctID = (structKeyExists(session, 'AcctID') ? session.AcctID : 0)>

		<cfreturn />
	</cffunction>

<!---
setAccount
--->
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

<!---
setPolicyID
--->
	<cffunction name="setPolicyID" output="true">
		<cfargument name="rc">

		<cfset rc.PolicyID = (structKeyExists(session, 'PolicyID') ? session.PolicyID : 0)>

		<cfreturn />
	</cffunction>

<!---
setPolicy
--->
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

<!--- close
	<cffunction name="close" output="false">
		<cfargument name="rc">
		
		<cfset variables.fw.service('security.close', 'nNewSearchID')>
				
		<cfreturn />
	</cffunction>
	<cffunction name="endclose" output="false">
		<cfargument name="rc">
		
		<cfset variables.fw.redirect('air.lowfare?SearchID=#rc.nNewSearchID#')>
		
		<cfreturn />
	</cffunction>
    --->
</cfcomponent>