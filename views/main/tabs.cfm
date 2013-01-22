<!--- <a id="helpdesktab" href="http://www.ithelpdesksoftware.com/help-desks.html">CID-LAS<br>1/1/2013</a>
<a id="blogtab" href="http://blog.ithelpdesksoftware.com/">New Search</a>
<a id="articlestab" href="http://www.ithelpdesksoftware.com/help-desk-articles.html">Hotel</a>
<a id="newstab" href="http://www.ithelpdesksoftware.com/help-desk-news.html">Car</a>
<a id="eventstab" href="http://www.ithelpdesksoftware.com/help-desk-events.html">Purchase</a> --->
<cfoutput>
	<!--- Any air tabs? --->
	<cfset bAir = 0>
	<cfloop array="#StructKeyArray(session.searches)#" index="nSearchID">
		<cfif session.searches[nSearchID].bAir>
			<cfset bAir = 1>
			<cfbreak>
		</cfif>
	</cfloop>
<!--- 
Show Air Tab(s)
--->
	<cfif bAir>
		<cfloop array="#StructKeyArray(session.searches)#" index="nSearchID">
			<cfif session.searches[nSearchID].bAir>
				<!--- <cfif rc.action CONTAINS 'air.' AND rc.nSearchID EQ nSearchID>selected</cfif> --->
				<a href="#buildURL('air.lowfare?Search_ID=#nSearchID#')#">
					#UCase(session.searches[nSearchID].sHeading)#
				</a>
						<!--- <cfif ArrayLen(StructKeyArray(session.searches)) GT 1>
							<a style="position:absolute;top:0px;left:140px;z-index:1005;" href="#buildURL('setup.close?Search_ID=#nSearchID#')#"><img src="assets/img/close.png"></a>
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
	<cfif (session.searches[nSearchID].bAir
	AND StructKeyExists(session.searches[nSearchID].stItinerary, 'Air'))
	OR NOT session.searches[nSearchID].bAir>
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
	<cfif (session.searches[nSearchID].bAir
	AND StructKeyExists(session.searches[nSearchID].stItinerary, 'Air'))
	OR NOT session.searches[nSearchID].bAir>
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