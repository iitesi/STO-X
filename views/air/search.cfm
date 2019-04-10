<cfoutput>
	<!--- #view('air/unusedtickets')# --->
	<div class="page-header">
		#View('air/legs')#
	</div>
	<div id="aircontent">
		<cfif NOT structIsEmpty(rc.trips)>
			<div>
				#View('air/pin')#
			</div>
			<div id="hidefilterfromprint">
				#View('air/filter2')#
			</div>
			<cfset variables.Fares = rc.trips.Fares>
			<cfset variables.BrandedFares = rc.trips.BrandedFares>
			<!--- Needs to be in the variables scope to be passed into the view. --->
			<cfset variables.trips = rc.trips>
			<div class="list-view container" id="listcontainer">
				<cfloop collection="#rc.trips.Segments#" index="segmentIndex" item="variables.Segment">
					<cfset variables.SegmentFares = structKeyExists(rc.trips.SegmentFares, segmentIndex) ? rc.trips.SegmentFares[segmentIndex] : {}>
					<cfif left(segmentIndex, 2) EQ 'G'&rc.group>
						#View('air/list')#
					</cfif>
				</cfloop>
			</div>
<!---
			<div class="clearfix"></div>
			<div class="noFlightsFound">
				<div class="container">
				<h1>No Flights Available</h1>
				<p>No flights are available for your filtered criteria. <a href="##" class="removefilters"><i class="fa fa-refresh"></i> Clear Filters</a> to see all results.</p>
				</div>
			</div>--->
		<cfelse>
			<div class="container">
				<h3>No Flights Returned</h2>
				<p>There were no flights found based on your search criteria.</p>
				<p>Please <a href="#application.sPortalURL#">change your search</a> and try again.</p>
				<br /><br /><br /><br /><br /><br />
			</div>
		</cfif>
	</div>

	<form method="post" action="#buildURL('air.search')#" id="lowfareavailForm">
		<input type="hidden" name="FlightSelected" value="1">
		<input type="hidden" name="SearchId" value="#rc.SearchID#">
		<input type="hidden" name="Group" value="#rc.Group#">
		<input type="hidden" name="SegmentId" id="SegmentId" value="">
		<input type="hidden" name="CabinClass" id="CabinClass" value="">
		<input type="hidden" name="SegmentFareId" id="SegmentFareId" value="">
		<input type="hidden" name="Refundable" id="Refundable" value="">
		<input type="hidden" name="Segment" id="Segment" value="">
	</form>
	<!---#View('modal/popup')#--->

</cfoutput>



<script type="application/javascript">
	function submitSegment(SegmentId,CabinClass,SegmentFareId,Refundable,Key) {
		$("#SegmentId").val(SegmentId);
		$("#CabinClass").val(CabinClass);
		$("#SegmentFareId").val(SegmentFareId);
		$("#Refundable").val(Refundable);
		$("#Segment").val($("#fare"+Key).val());
		$("#lowfareavailForm").submit();
	}
	$('.filteroption').on('click', function (e) {
		e.preventDefault();
		// set variables.
		var stops = $(this).data('stops');
		//var carriers = [];
		//$.each($("input[name='carrier']:checked"), function(){            
		//	carriers.push($(this).val());
		//});
		// hide all
		$('#listcontainer > div').hide();
		// display appropriate divs
		$('#listcontainer > div[data-stops="'+stops+'"]').show();
		console.log(stops);
		//console.log(carriers);
	});
	function sortTrips(dataelement) {
		var divList = $('.trip');
		divList.sort(function(a, b){
			return $(a).data(dataelement)-$(b).data(dataelement)
		});
		$("#listcontainer").html(divList);
	}
	function refundable(refundable) {
		$('.fares').hide();
		$('.fares[data-refundable="'+refundable+'"]').show();
	}
</script>
<cfdump var=#session.Searches[rc.SearchID].Selected#>
<cfdump var=#rc.trips.Profiling#>