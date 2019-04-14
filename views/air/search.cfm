<cfoutput>
	<div class="row">
		<!--- 
		<div class="col-sm-12">
			#view('air/unusedtickets')# 
		</div>
		--->
		<div class="col-sm-12">
			<div class="paage-header"> <!-- TODO fix styles -->
				#View('air/legs')#
			</div>
		</div>
		<div class="col-sm-12" id="aircontent">
			<div class="row">
			<cfif NOT structIsEmpty(rc.trips)>
				<div class="col-sm-12">
					#View('air/pin')#
				</div>
				<div class="col-sm-12" id="hidefilterfromprint">
					#View('air/filter2')#
				</div>
				<cfset variables.Fares = rc.trips.Fares>
				<cfset variables.BrandedFares = rc.trips.BrandedFares>
				<!--- Needs to be in the variables scope to be passed into the view. --->
				<cfset variables.trips = rc.trips>
				<div class="list-view col-sm-12" id="listcontainer">
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
	
	</div>
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
		
		function sortTrips(dataelement) {
			var divList = $('.trip');
			divList.sort(function(a, b){
				return $(a).data(dataelement)-$(b).data(dataelement)
			});
			$("#listcontainer").html(divList);
		}

		$('#listcontainer').on('click', '.detail-expander', function () {
			$(this).parents(".panel.trip").toggleClass("active");
		});  

		$('#listcontainer').on('dblclick touchstart', '.panel.trip', function (e) {
			var $target = $(e.target);
			if(!$target.closest(".fare-wrapper").length){
				$(this).find('.detail-expander').trigger('click');
			}
		});  

		$('[data-toggle="tooltip"].flight-result-warning').tooltip({
			template: '<div class="tooltip flight-warning" role="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>'
		});
		$('[data-toggle="tooltip"].fare-warning').tooltip({
			template: '<div class="tooltip faretooltip" role="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>'
		}); 
		

		$('#filterbar a.dropdown-toggle').on('click', function (e) {
			var $target = $(e.target);
			var $ddown = $target.parent();
			var $others = $('#filterbar a.dropdown-toggle').parent().filter(function(){
				return $(this).attr('id') != $ddown.attr('id');
			})
			$others.removeClass('open')
			$(this).parent().toggleClass('open');
		});

		$('body').on('click', function (e) {
			var $target = $(e.target);
			var $ddown = $target.closest('.dropdown');
			if (!$ddown.length){
				$('#filterbar .dropdown.open').removeClass('open')
			}
		});


		/* Setup the filters, and do any validation prior to use */
		$('.singlefilter').each(function(){
			var $input = $(this);
			var name = $input.attr('name');
			var value = $input.val();
			var element = $input.data('element');
			var $matches;

			if(value == -1) return;

			if ("fares" == element){
				$matches = $('#listcontainer .fares[data-'+name+'="'+value+'"]');
			}
			else {
				$matches = $('#listcontainer > div[data-'+name+'="'+value+'"]');
			}

			if (!$matches.length){
				$input.prop('disabled', true);
				$input.parent().addClass('disabled');
			}
			else{
				$input.next().html( $input.next().html() + " <span>(" + $matches.length + ")</span>")
			}
		});

		$('.multifilterwrapper').each(function(){
			var $wrapper = $(this);
			var name = $wrapper.data('name');
			var type = $wrapper.data('type');
			var element = $wrapper.data('element');
			var $matches;
			
			if ("fares" == element){
				$matches = $('#listcontainer .fares[data-'+name+']');
			}
			else {
				$matches = $('#listcontainer > div[data-'+name+']');
			}
			var values = [];
			$matches.each(function(){
				var data = $(this).data(name);
				var items = data.replace(/ /gi,'').split(',');
				for(var i=0;i<items.length;i++){
					var item = $.trim(items[i]);
					if(!values.includes(item)){
						values.push(item);
					}
				}
			});
			var finalValues = values.sort();

			for(var x = 0; x < finalValues.length; x++){
				var value = finalValues[x];
				var $input = $('<li><div class="md-checkbox"><input id="'+name+'-'+x+'" checked class="multifilter" type="checkbox" name="'+
				name+'" value="'+value+'" data-title="'+value+'" title="'+value+'"><label for="'+
				name+'-'+x+'">'+value+'</label><div data-multiselect-only>only</div></div></li>')
				$wrapper.append($input);
			}

		});

		$('#filterbar').on('click', '[data-multiselect-only]', function (e) {
			e.stopImmediatePropagation();
			preFilter();
			var $link = $(this);
			var $input = $link.parent().find('input[type=checkbox]')
			var $wrapper = $link.parents('.multifilterwrapper');
			var name = $input.attr('name');
			var value = $input.val();
			
			$wrapper.find('.multifilter').each(function(){
				$(this).prop('checked',$(this).val()==value);
			});

			doFilter();
			postFilter();
		});

		$('#filterbar').on('click', '.multifilter', function (e) {
			preFilter();
			doFilter();
			postFilter();
		});

		$('#filterbar').on('change', '.singlefilter', function (e) {
			preFilter();
			doFilter();
			postFilter();
		});

		var preFilter = function(){
			$(".trip .detail-expander[aria-expanded=true]").trigger('click');
		}

		var doFilter = function(){
			var filters = {
				stops: getGroupValue('stops'),
				refundable: getGroupValue('refundable'),
				connection: getGroupValue('connection')
			};
			var filterKeys = Object.keys(filters);
			$('#listcontainer > div').each(function(){
				var $this = $(this);

				const matches = filterKeys.every(function(key){
					try {
						if (filters[key] == -1) {
							return true;
						}
						switch(key){
							case 'stops': {
								return $this.data('stops') == filters[key];
								break;
							}
							case 'refundable': {
							// TODO show/hide the cabin
								return true;
								break;
							}
							case 'connection': {
								var airports = $this.data('connection');
								var airportArray = airports.replace(/ /gi, '').split(',');
								return airportArray.every(function(code){
									return filters[key].includes(code);
								});
								break;
							}
						}
					}
					catch(e){
						return true;
					}
				});
				matches ? $this.show() : $this.hide();
			});
		}

		var postFilter = function(){
			$('#listcontainer > div').removeClass('first-visible-child').removeClass('last-visible-child');
			$('#listcontainer > div:visible:first').addClass('first-visible-child');
			$('#listcontainer > div:visible:last').addClass('last-visible-child');
			// TODO cleanup the available values in other selections now.  i.e., filtering to 1 stop
			// should affect the valid values in the connecting airports drop down.  Need to disable
			// or enable ones that are/aren't valid now
		}

		var getGroupValue = function(name){
			var $item = $('input[name='+name+']:first','#filterbar');
			var type = $item.attr('type');
			if ( type == 'radio'){
				return $('input[name='+name+']:checked','#filterbar').val()
			}
			else if ( type == 'checkbox'){
				return $('input[name='+name+']:checked','#filterbar').map(function(){
					return $(this).val();
				}).get();
			}
		}

		postFilter();
	</script>
	
	<div class="row">
	<cfdump var=#session.Searches[rc.SearchID].stItinerary.Air#>
	<cfdump var=#rc.trips.Profiling#>
	</div>

	<li>
		<div class="md-checkbox">
			<input id="connection-a" class="multifilter" type="checkbox" name="conection" data-value="-1" data-title="Any Connecting Airports" title="Any Connecting Airports">
			<label for="connection-a">Any Connecting Airports</label>
		</div>
	</li>