<cfif rc.action EQ 'air.lowfare' OR rc.action EQ 'air.availability'>
	<cfif ArrayLen(StructKeyArray(session.searches)) GT 1>
		<!---How many searches include air?--->
		<cfset nAirCount = 0>
		<cfloop collection="#session.filters#" index="filterSearchID">
			<cfif session.filters[filterSearchID].getAir()>
	            <cfset nAirCount++>
			</cfif>
		</cfloop>
		<!---Display searches if there are more than one available with air.--->
		<cfif nAirCount GT 1>
			<cfset nTempCount = 0>
			<cfoutput>

				<li><a href="" class="btn btn-mini">New Search</a></li>


				<cfloop collection="#session.filters#" index="filterSearchID">
					<cfif session.filters[filterSearchID].getAir()>
						<cfset nTempCount++>
						<li>
			        <a href="#buildURL('air.lowfare?SearchID=#filterSearchID#')#" <cfif filterSearchID EQ rc.SearchID>class="active"</cfif>>#UCase(session.filters[filterSearchID].getHeading())#</a>
							<i class="icon-remove"></i>
							<cfif nAirCount NEQ nTempCount><span class="divider">/</span></cfif>
	          </li>
					</cfif>
				</cfloop>
			</cfoutput>
		</cfif>
	</cfif>
</cfif>