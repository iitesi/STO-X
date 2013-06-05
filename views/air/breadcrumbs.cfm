<cfif rc.action EQ 'air.lowfare' OR rc.action EQ 'air.availability'>
	<cfif ArrayLen(StructKeyArray(session.searches)) GTE 1>
		<!---How many searches include air?--->
		<cfset nAirCount = 0>
		<cfloop collection="#session.filters#" index="filterSearchID">
			<cfif session.filters[filterSearchID].getAir()>
							<cfset nAirCount++>
			</cfif>
		</cfloop>

		<cfset nTempCount = 0>
			<cfoutput>
				<div class="row">
					<div class="2 columns alpha newsearch">

						<!---
						TODO: switch this out to use modal window to call widget STM-652
						10:37 AM Tuesday, June 04, 2013 - Jim Priest - jpriest@shortstravel.com
						--->
						<a href="/search/?acctid=1&userid=3605" class="btn btn-mini">New Search</a>


					</div>
					<div class="fourteen columns omega">
						<ul class="breadcrumb">
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
						</ul>
					</div>
				</div>
			</cfoutput>
	</cfif>
</cfif>