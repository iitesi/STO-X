<cfoutput>
	<div class="summarydiv container-fluid">
		<table width="100%" cellpadding="0" cellspacing="0">
			<tr>
				<td>
					<!--- If flight --->
					<cfif rc.airSelected>
						<cfoutput>
							#view('confirmation/air')#
						</cfoutput>
						<cfif rc.hotelSelected OR rc.vehicleSelected>
							<hr />
						</cfif>
					</cfif>
					<!--- If hotel --->
					<cfif rc.hotelSelected>
						<cfoutput>
							#view('confirmation/hotel')#
						</cfoutput>
						<cfif rc.vehicleSelected>
							<hr />
						</cfif>
					</cfif>
					<!--- If car --->
					<cfif rc.vehicleSelected>
						<cfoutput>
							#view('confirmation/vehicle')#
						</cfoutput>
					</cfif>
				</td>
			</tr>
		</table>
	</div>
</cfoutput>
