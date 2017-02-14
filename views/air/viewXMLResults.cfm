<cfoutput>
<h3>uAPI Result Viewer</h3>
<cfif !rc.showSegments>
<form method="post" action="#buildURL('air.viewXMLResults')#" id="lowfareForm">
<textarea name="XMLToTest" rows="20" style="width:100%;">#rc.XMLToTest#</textarea><br/>
<input type="submit" name="submit" value="View XML" />
</form>
<cfif len(rc.XMLToTest)>
<form method="post" action="#buildURL('air.viewXMLResults&showSegments=true')#" target="_blank"  id="lowfareForm2">
<textarea name="XMLToTest" style="width:0px;height:0px">#rc.XMLToTest#</textarea><br/>
<input type="submit" name="submit" value="View Segments" />
</form>
</cfif>
</cfif>
<br/>
<cfif StructCount(rc.segments) GT 0>
<cfdump var="#rc.segments#">
</cfif>
<cfset ctr = 0>
<cfloop collection="#rc.trips#" item="trip">
<cfset ctr++>
<span style="font-weight:bold !important;color:red">FLIGHT: #rc.trips[trip].key#</span><br/>
<cfset segments = {}>
<cfset segments = rc.trips[trip].segments>
<cfset g = 0>
<cfloop collection="#segments#" item="segment">
<cfif #segments[segment].group# NEQ g>
  <cfset g = #segments[segment].group#>
  <br/>
</cfif>
#segments[segment].group#:#segments[segment].flightnumber#: #segments[segment].origin# - #segments[segment].destination# : #segments[segment].cabin#<br>
</cfloop>
<a href='javascript:$( "##xml_#ctr#" ).toggle( "fast", function() {});' id="link_on_#ctr#">toggle xml</a>
<div id="xml_#ctr#" style="width:600px;display:none;">
<cfdump var="#rc.trips[trip].XML#">
</div><br><br>
</cfloop>
</cfoutput>
