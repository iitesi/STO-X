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
					<cfscript>
						airlines = {};
						connectingAirports = {};
					</cfscript>
					<cfloop collection="#rc.trips.Segments#" index="segmentIndex" item="variables.Segment">
						<cfscript>
							if( structKeyExists(variables.Segment, 'Connections')){
								connectionCodes = listToArray(variables.Segment.Connections);
								for (i=1; i <= arrayLen(connectionCodes);i=i+1) {
									airportCode = trim(connectionCodes[i])
									if(!structKeyExists(connectingAirports,airportCode) AND structKeyExists(application.stAirports, airportCode)){
										structInsert(connectingAirports, airportCode, application.stAirports[airportCode].City)
									}
								}
							}		
							if( structKeyExists(variables.Segment, 'CarrierCode')){
								carrierCode = variables.Segment.CarrierCode;
								if(!structKeyExists(airlines,carrierCode) AND structKeyExists(application.stAirVendors, carrierCode)){
									structInsert(airlines, carrierCode, application.stAirVendors[carrierCode].Name)
								}
							}						
						</cfscript>
						<cfset variables.SegmentFares = structKeyExists(rc.trips.SegmentFares, segmentIndex) ? rc.trips.SegmentFares[segmentIndex] : {}>
						<cfif left(segmentIndex, 2) EQ 'G'&rc.group>
							#View('air/list')#
						</cfif>
					</cfloop>
				</div>
				<div class="col-sm-12 noFlightsFound panel panel-default">
					<h1>No Flights Available</h1>
					<p>No flights are available for your filtered criteria. <a href="##" class="removefilters"><i class="fa fa-refresh"></i> Clear Filters</a> to see all results.</p>
				</div>
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

		var airportCities = <cfoutput>#serializeJSON(connectingAirports)#</cfoutput>;
		var airlines = <cfoutput>#serializeJSON(airlines)#</cfoutput>;

		function submitSegment(SegmentId,CabinClass,SegmentFareId,Refundable,Key) {
			$("#SegmentId").val(SegmentId);
			$("#CabinClass").val(CabinClass);
			$("#SegmentFareId").val(SegmentFareId);
			$("#Refundable").val(Refundable);
			$("#Segment").val($("#fare"+Key).val());
			$("#lowfareavailForm").submit();
		}

		function sendEmail(Key) {
			$("#Email_Segment").val($("#fare"+Key).val());
		}
		
		function sortTrips(dataelement) {
			var divList = $('.trip');
			divList.sort(function(a, b){
				return $(a).data(dataelement)-$(b).data(dataelement)
			});
			$("#listcontainer").html(divList);
			postFilter();
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

		$('body').tooltip({
			selector: '[data-toggle="tooltip"].flight-result-warning',
			template: '<div class="tooltip flight-warning" role="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>'
		});
		$('#listcontainer').tooltip({
			selector: '[data-toggle="tooltip"].fare-warning',
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

		var multiFilterLabel = function(name,value){
			if(name=='connection'){
				return airportCities[value] + " (" + value + ")";
			}
			if(name=='airline'){
				return airlines[value];
			}
			return value;
		}

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
				name+'-'+x+'">'+multiFilterLabel(name,value)+'</label><div data-multiselect-only>only</div></div></li>')
				$wrapper.append($input);
			}

		});

		var sliderMinMaxValues = function(times){
			var min = times[0];
			var max = times[times.length-1];
			var total = max - min;
			var hours = Math.ceil(total / 60) + 1;
			var spots = [];
			var start = Math.floor(min / 60);

			for (var x = 0; x < hours; x++){
				spots.push(start + x + 'h');
				spots.push(start + x + 'h 30m');
			}

			spots.push(hours + 'h');
			return spots;
		}

		$(".range-slider").each(function(){
			var $ul = $(this);
			var selector = $ul.data('selector');
			var datafield = $ul.data('datafield');
			var $trips = $('#listcontainer').find('.' + selector);
			var times = $trips.map(function(){return $(this).data(datafield) - 0;}).get();
			var sorted = times.sort(function(a,b){return a-b});
			var customValues = sliderMinMaxValues(sorted);
			var $input = $ul.find('.js-range-slider');
			var slider = $input.data('ionRangeSlider');
			if (slider){
				slider.destroy();
			}

			$input.ionRangeSlider({
				skin: "round",
				type: "double",			
				from: 0,
				to: customValues.length - 1,
				values: customValues,
				onFinish: function (data) {
					preFilter();
					doFilter();
					postFilter();
				},
			});
		});

		$(".time-slider").each(function(){
			var $ul = $(this);
			var $input = $ul.find('.js-range-slider');
			var slider = $input.data('ionRangeSlider');
			if (slider){
				slider.destroy();
			}

			var customValues = [];
			// customValues.push('12:00 am');

			for (var a = 0; a <= 24; a++){
				var h = a % 12 || 12;
				var ampm = (a < 12 || a === 24) ? "am" : "pm";
				customValues.push( h + ':00 ' + ampm);
			}

			$input.ionRangeSlider({
				skin: "round",
				type: "double",			
				from: 0,
				to: customValues.length - 1,
				values: customValues,
				onFinish: function (data) {
					preFilter();
					doFilter();
					postFilter();
				},
			});


			$input.ionRangeSlider({
				skin: "round",
				type: "double",			
				from: 0,
				to: customValues.length - 1,
				values: customValues,
				onFinish: function (data) {
					preFilter();
					doFilter();
					postFilter();
				},
			});
		});

		$('#filterbar').on('click', '[data-multiselect-only]', function (e) {
			e.stopImmediatePropagation();
			preFilter();
			var $link = $(this);
			var $input = $link.parent().find('input[type=checkbox]')
			var $wrapper = $link.parents('.multifilterwrapper');
			var $switch = $wrapper.find('.switch-input');
			var name = $input.attr('name');
			var value = $input.val();
			
			$switch.prop('checked',false);

			$wrapper.find('.multifilter').each(function(){
				$(this).prop('checked',$(this).val()==value);
			});

			doFilter();
			postFilter();
		});

		$('#filterbar').on('click', '.switch-label', function (e) {
			e.stopImmediatePropagation();
			preFilter();
			var $label = $(this);
			var $item = $label.prev();
			var $wrapper = $item.parents('.multifilterwrapper');
			
			$wrapper.find('.multifilter').each(function(){
				$(this).prop('checked',!$item.is(':checked'));
			});

			doFilter();
			postFilter();
		});

		$('#filterbar').on('click', '.multifilter', function (e) {
			preFilter();

			var $link = $(this);
			var $wrapper = $link.parents('.multifilterwrapper');
			var $inputs = $wrapper.find('input[type=checkbox].multifilter');
			var $checkedInputs = $wrapper.find('input[type=checkbox].multifilter:checked');
			var $switch = $wrapper.find('.switch-input');
			if($switch.length){
				var switchOn = $checkedInputs.length == 0 ? false : $checkedInputs.length == $inputs.length ? true : false;
				$switch.prop('checked', switchOn);
			}

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

		var getMinutesFromString = function(str){
			var values = str.split(' ');
			if ( values.length == 1 ){
				return Number(values[0].replace(/[^0-9]/g,'') * 60);
			}
			if ( values.length == 2 ){
				var hours = Number(values[0].replace(/[^0-9]/g,''));
				var minutes = Number(values[1].replace(/[^0-9]/g,''));
				return (hours * 60) + minutes
			}
		}

		var rangeDetails = function(field){
			try {
				var data = $("input[name='"+field+"-range']").data('ionRangeSlider').result;
				var values = [];
				values.push(getMinutesFromString(data.from_value));
				values.push(getMinutesFromString(data.to_value));
				return values;
			}
			catch(e){
			}
			return [0,9999];
		}

		var rangeRawValue = function(field){
			try {
				var data = $("input[name='"+field+"-range']").data('ionRangeSlider').result;
				var values = [];
				values.push(data.from);
				values.push(data.to);
				return values;
			}
			catch(e){
			}
			return [0,9999];
		}

		var doFilter = function(){
			var filters = {
				stops: getGroupValue('stops'),
				refundable: getGroupValue('refundable'),
				connection: getGroupValue('connection'),
				layover: rangeDetails('layover'),
				duration: rangeDetails('duration'),
				airline: getGroupValue('airline'),
				departure : rangeRawValue('departure'),
				arrival : rangeRawValue('arrival')
			};
			// console.log(filters)
			var filterKeys = Object.keys(filters);
			$('#listcontainer > div').each(function(){
				var $this = $(this);

				const matches = filterKeys.every(function(key){
					try {
						if (!Array.isArray(filters[key]) && filters[key] == -1) {
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
								for (var a=0;a<airportArray.length;a++){
									if(filters[key].includes(airportArray[a])){
										return true;
									}
								}
								return false;
								break;
							}
							case 'departure': {
							}
							case 'arrival': {
								var timestamp = $this.data(key);
								var dtime = moment(timestamp,'YYYYMMDDHHmm');
								return dtime.hour() >= filters[key][0] && dtime.hour() <= filters[key][1]
								break;
							}
							case 'airline': {
								return filters[key].includes($this.data('airline'));
								break;
							}
							case 'duration' : {
								var time = $this.data('duration');
								return time >= filters.duration[0] && time <= filters.duration[1];
							}
							case 'layover' : {
								var $layovers = $this.find('.segment-stopover');
								if (!$layovers.length) {
									return true;
								}
								var matches = true;
								var times = $layovers.map(function(){return $(this).data('minutes') - 0;}).get();
								return times.every(function(time){
									return time >= filters.layover[0] && time <= filters.layover[1];
								});
							}
							default: {
								return true;
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
			setTimeout(function(){
				var visibleTrips = $('#listcontainer > div.trip:visible').length;
				$("#resultsCount span").html(visibleTrips);
				visibleTrips <= 0 ? $('#listcontainer + .noFlightsFound').show() : $('#listcontainer + .noFlightsFound').hide();
			},400);

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

		sortTrips('economy');
		postFilter();
	</script>
	
<div class="row">
	<cfoutput>
		#View('air/email')#
	</cfoutput>
</div>
	
<div class="row">
	<cfdump var=#structKeyList(rc.trips)#>
	<cfdump var=#session.Searches[rc.SearchID].stItinerary.Air#>
	<cfdump var=#rc.trips.Profiling#>
</div>
