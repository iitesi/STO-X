
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
				<a href="#buildURL('air.lowfare?Search_ID=#SearchID#')#">
					#UCase(rc.Filter.getHeading())#
				</a>
						<!--- <cfif ArrayLen(StructKeyArray(session.searches)) GT 1>
							<a style="position:absolute;top:0px;left:140px;z-index:1005;" href="#buildURL('setup.close?Search_ID=#SearchID#')#"><img src="assets/img/close.png"></a>
						</cfif> --->
			</cfif>
		</cfloop>
		<!--- <a href="#buildURL('hotel?Search_ID=#rc.Search_ID#')#">
			<h3>New Air Search</h3>
		</a> --->
	</cfif>
<!--- 
Show Hotel Tab(s)
--->
	<cfif (rc.Filter.getAir()
	AND StructKeyExists(session.searches[SearchID].stItinerary, 'Air'))
	OR NOT rc.Filter.getAir()>
		<a href="#buildURL('hotel.search?Search_ID=#rc.Search_ID#')#">
			HOTEL
		</a>
	<cfelse>
		<a href="#buildURL('hotel.search?Search_ID=#rc.Search_ID#')#">
			HOTEL
		</a>
	</cfif>
<!--- 
Show Car Tab(s)
--->
	<cfif (rc.Filter.getAir()
	AND StructKeyExists(session.searches[SearchID].stItinerary, 'Air'))
	OR NOT rc.Filter.getAir()>
		<a href="#buildURL('car.availability?Search_ID=#rc.Search_ID#')#">
			CAR
		</a>
	<cfelse>
		<a href="#buildURL('car.availability?Search_ID=#rc.Search_ID#')#">
			CAR
		</a>
	</cfif>
<!---
Summary
--->
	<a href="#buildURL('summary?Search_ID=#rc.Search_ID#')#">
		Summary/Purchase
	</a>
<!---
Reload Air
--->
	<a href="#buildURL('air.lowfare?Search_ID=#rc.Search_ID#&bReloadAir=')#">
		Reload Air
	</a>
</cfoutput>