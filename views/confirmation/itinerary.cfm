<cfoutput>
	<div class="carrow" style="width:946px;padding:0px;margin-bottom:26px;">
		<table width="100%" cellpadding="0" cellspacing="0">
			<tr>
				<td>
					<!--- If flight --->
					<cfif rc.airSelected>
						<cfoutput>
							#view('confirmation/air')#
						</cfoutput>
					</cfif>
					<hr />
					<!--- If hotel --->
					<cfif rc.hotelSelected>
						<cfoutput>
							#view('confirmation/hotel')#
						</cfoutput>
					</cfif>
					<hr />
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