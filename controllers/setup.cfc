<cfcomponent output="false">

	<cfset variables.fw = "">
	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="fw">
		<cfset variables.fw = arguments.fw>
		<cfreturn this>
	</cffunction>

<!--- setup : setApplication --->
	<cffunction name="setApplication" output="false" returntype="void">
		
		<cfif NOT StructKeyExists(application, 'objUAPI')>
			<cfset variables.fw.service('setup.loadObjUAPI', 'void')>
		</cfif>
		<!--- <cfif NOT StructKeyExists(application, 'objAirPrice')> --->
			<cfset variables.fw.service('setup.loadObjects', 'void')>
		<!--- </cfif> --->
		<cfif NOT StructKeyExists(application, 'sServerURL') OR application.sServerURL EQ ''>
			<cfset variables.fw.service('setup.setServerURL', 'void')>
		</cfif>
		<cfif NOT StructKeyExists(application, 'sPortalURL') OR application.sPortalURL EQ ''>
			<cfset variables.fw.service('setup.setPortalURL', 'void')>
		</cfif>
		<cfif NOT StructKeyExists(application, 'sAPIAuth') OR application.sAPIAuth EQ ''>
			<cfset variables.fw.service('setup.setAPIAuth', 'void')>
		</cfif>
		<cfif NOT StructKeyExists(application, 'stAccounts') OR StructIsEmpty(application.stAccounts)>
			<cfset variables.fw.service('setup.setAccounts', 'void')>
		</cfif>
		<cfif NOT StructKeyExists(application, 'stPolicies') OR StructIsEmpty(application.stPolicies)>
			<cfset variables.fw.service('setup.setPolicies', 'void')>
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


<!--- setup : setSession --->
	<cffunction name="setSession" access="public" output="true">
		
		<cfset variables.fw.service('security.search', 'search')>
		
		<cfreturn />
	</cffunction>
	
<!--- close --->
	<cffunction name="close" output="false">
		<cfargument name="rc">
		
		<cfset rc.nSearchID = url.Search_ID>
		<cfset variables.fw.service('security.close', 'nNewSearchID')>
				
		<cfreturn />
	</cffunction>
	<cffunction name="endclose" output="false">
		<cfargument name="rc">
		
		<cfset variables.fw.redirect('air.lowfare?Search_ID=#rc.nNewSearchID#')>
		
		<cfreturn />
	</cffunction>
	
</cfcomponent>