<style>
	.minlineheight {
		line-height: 10px;
	}
	hr {
		margin-bottom: 0px;
	}
	.dashed {
		border: dashed #2E76CF;
		border-width: 1px 0 0 0;
		height: 0;
		line-height: 0px;
		font-size: 0;
		margin: 4px 0 4px 0;
		padding: 0;
	}
	.ribbon {
		position: relative;
	}
</style>

<!--- <cfdump var="#session.searches[rc.SearchID].travelers#" label="session.searches[rc.SearchID].travelers" abort> --->

<div style="width:1000px;">
	<div class="container">
		<div class="page-header">
			<cfoutput>
				<h1>RESERVATION CREATED</h1>
			</cfoutput>
		</div>
	</div>
	<div>
		<div id="reservationMessage" class="alert alert-success">
			<!--- TO DO: Put in cfif logic when not a pre-trip. --->
			WE HAVE CREATED YOUR RESERVATION AND EMAILED YOUR TRAVEL MANAGER FOR APPROVAL.<br />
			YOU WILL RECEIVE AN EMAIL CONFIRMATION ONCE YOUR MANAGER HAS APPROVED.
		</div>
	</div>
	<div style="height:14px;"></div>
	<div>
		<span class="blue confirm-header">BILLING DETAILS</span>
	</div>
	<cfoutput>
		#view('confirmation/billing')#
	</cfoutput>
	<div>
		<span class="blue confirm-header">ITINERARY</span>
	</div>
	<cfoutput>
		#view('confirmation/itinerary')#
	</cfoutput>
</div>