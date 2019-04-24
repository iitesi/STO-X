
<cfoutput>
	<!--- Any air tabs? --->
	<cfset Air = 0>
	<cfloop collection="#session.Filters#" index="SearchID" item="stFilter">
		<cfif stfilter.getAir()>
			<cfset Air = 1>
			<cfbreak>
		</cfif>
	</cfloop>
<!--- 
Show Air Tab(s)
--->
	<cfif Air>
		<cfloop array="#StructKeyArray(session.searches)#" index="SearchID">
			<cfif rc.Filter.getAir()>
				<!--- <cfif rc.action CONTAINS 'air.' AND rc.SearchID EQ SearchID>selected</cfif> --->
				<a href="#buildURL('air?SearchID=#SearchID#')#">
					#UCase(rc.Filter.getHeading())#
				</a>
						<!--- <cfif ArrayLen(StructKeyArray(session.searches)) GT 1>
							<a style="position:absolute;top:0px;left:140px;z-index:1005;" href="#buildURL('setup.close?SearchID=#SearchID#')#"><img src="assets/img/close.png"></a>
						</cfif> --->
			</cfif>
		</cfloop>
		<!--- <a href="#buildURL('hotel?SearchID=#rc.SearchID#')#">
			<h3>New Air Search</h3>
		</a> --->
	</cfif>
<!--- 
Show Hotel Tab(s)
--->
	<cfif (rc.Filter.getAir()
	AND StructKeyExists(session.searches[SearchID].stItinerary, 'Air'))
	OR NOT rc.Filter.getAir()>
		<a href="#buildURL('hotel.search?SearchID=#rc.SearchID#')#">
			HOTEL
		</a>
	<cfelse>
		<a href="#buildURL('hotel.search?SearchID=#rc.SearchID#')#">
			HOTEL
		</a>
	</cfif>
<!--- 
Show Car Tab(s)
--->
	<cfif (rc.Filter.getAir()
	AND StructKeyExists(session.searches[SearchID].stItinerary, 'Air'))
	OR NOT rc.Filter.getAir()>
		<a href="#buildURL('car.availability?SearchID=#rc.SearchID#')#">
			CAR
		</a>
	<cfelse>
		<a href="#buildURL('car.availability?SearchID=#rc.SearchID#')#">
			CAR
		</a>
	</cfif>
<!---
Summary
--->
	<a href="#buildURL('summary?SearchID=#rc.SearchID#')#">
		Summary/Purchase
	</a>
<!---
Reload Air
--->
	<a href="#buildURL('air?SearchID=#rc.SearchID#&bReloadAir=')#">
		Reload Air
	</a>
</cfoutput>