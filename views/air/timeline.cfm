<cfoutput>
	#View('air/legs')#
	#View('air/filter')#
</cfoutput>
<br clear="both">
<div id="aircontent">
	<cfif structKeyExists(session.searches[rc.SearchID].stAvailDetails.aSortDuration, rc.Group)>
	    <script type="text/javascript" src="assets/js/timeline.js"></script>
	    <link rel="stylesheet" type="text/css" href="assets/js/timeline.css">
	    <style type="text/css">
	    body {
	        font-size: 10pt;
	        font-family: verdana, sans, arial, sans-serif;
	    }
		div.timeline-event {
			height:25px;
		}
		div.timeline-event-content {
			height:20px;
			font-size: 10px;
		}
		div.UA {
			background-color: blue;
			border-color: darkblue;
			color: white;
		}
		div.US {
			background-color: black;
			border-color: black;
			color: white;
		}
		div.DL {
			background-color: red;
			border-color: darkred;
			color: white;
		}
		div.AA {
			background-color: gold;
			border-color: gold;
			color: black;
		}
		div.layover {
			background-color: white;
			color: #666666;
		}
	    </style>
		<cfoutput>
			<cfsavecontent variable="jsondata">
				<cfset Count = 0>
				<cfloop array="#session.searches[rc.SearchID].stAvailDetails.aSortDuration[rc.Group]#" index="i">
					<cfset TotalSegments = ArrayLen(StructKeyArray(session.searches[rc.SearchID].stAvailTrips[rc.Group][i].Groups[0].Segments))>
					<cfset SegmentCount = 0>
					<cfloop collection="#session.searches[rc.SearchID].stAvailTrips[rc.Group][i].Groups[0].Segments#" index="j">
						<cfset Count++>
						<cfset SegmentCount++>
						<cfset stSegment = session.searches[rc.SearchID].stAvailTrips[rc.Group][i].Groups[0].Segments[j]>
						<cfif Count NEQ 1>,</cfif>
						{
							'start':new Date(#DateFormat(stSegment.DepartureGMT, 'yyyy,m,d,')##TimeFormat(stSegment.DepartureGMT, 'HH,mm,00')#),
							'end':new Date(#DateFormat(stSegment.ArrivalGMT, 'yyyy,m,d,')##TimeFormat(stSegment.ArrivalGMT, 'HH,mm,00')#),
							'content':'<img src="assets/img/airlines/#stSegment.Carrier#_sm.png" style="float:left;position:relative;"> #stSegment.Carrier# #stSegment.FlightNumber# (#stSegment.Origin# to #stSegment.Destination#)',
							'group':'#i#'
						}
						<cfif TotalSegments NEQ SegmentCount>
							,{
								'start':new Date(#DateFormat(stSegment.ArrivalGMT, 'yyyy,m,d,')##TimeFormat(stSegment.ArrivalGMT, 'HH,mm,00')#),
								<cfset stNextSegment = session.searches[rc.SearchID].stAvailTrips[rc.Group][i].Groups[0].Segments[j+1]>
								<cfset layoverTime = DateDiff('n', stSegment.ArrivalGMT, stNextSegment.DepartureGMT)>
								'end':new Date(#DateFormat(stNextSegment.DepartureGMT, 'yyyy,m,d,')##TimeFormat(stNextSegment.DepartureGMT, 'HH,mm,00')#),
								'content':'Layover in #stNextSegment.Origin# for #int(layoverTime/60)#h #layoverTime%60#m',
								'group':'#i#',
								'className': 'layover'
							}
						</cfif>
					</cfloop>
				</cfloop>
			</cfsavecontent>
		</cfoutput>
	    <script type="text/javascript">
	        var timeline;
	        var data;
	        // Called when the Visualization API is loaded.
	        function drawVisualization() {
	            // Create a JSON data table
	            data = [<cfoutput>#jsondata#</cfoutput>];

	            // specify options
	            var options = {
	                'width':  '100%',
	                'editable': false,   // enable dragging and editing events
	                'style': 'box',
	                'axisOnTop':'true'
	            };

	            // Instantiate our timeline object.
	            timeline = new links.Timeline(document.getElementById('mytimeline'));

	            function onRangeChanged(properties) {
	                document.getElementById('info').innerHTML += 'rangechanged ' +
	                        properties.start + ' - ' + properties.end + '<br>';
	            }

	            // attach an event listener using the links events handler
	            links.events.addListener(timeline, 'rangechanged', onRangeChanged);

	            // Draw our timeline with the created data and options
	            timeline.draw(data, options);
	        }
	    </script>
	</head>
	<body onload="drawVisualization();">
	<div id="mytimeline"></div>
</cfif>