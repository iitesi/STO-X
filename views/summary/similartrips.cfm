<style>
#similarTrips{
  margin-top:10px;
}
.similarTrip{
	width:290px;
	height:70px;
	padding:3px;
	border:1px silver solid;
	border-radius: 5px;
	float:left;
	margin-right:5px;
  cursor:pointer;
}
.similarTrip .dateString{
  font-size: 12px;
  font-weight: bold;
  font-family:Verdana;
}
.similarTrip .pnrInfo{
  color:#3279E5;
}

.similarTripSelected{
  background-color: #3279E5 !important;
}
.similarTripSelected .dateString{
  color: white !important;
}
.similarTripSelected .pnrInfo{
  color:white !important;
}

.unselectSimilarTrip{
  color:#3279E5;
  cursor: pointer;
}

.activeTrip{
  font-weight:bold;
  font-family: Verdana;
  color: white;
  marigin-bottom:2px;
}
</style>
<cfoutput>
<h2>SIMILAR TRIPS</h2>
<span>We found an existing trip for similar dates below.  Please select the trip if you would like to add this purchase to the same reservation.</span>
<div id="similarTrips">
</div>	<br style="clear:both;" />
<a class="unselectSimilarTrip">Unselect Trip</a>
<input type="hidden" name="PNRHdrID" value="0">
</cfoutput>
<cfsilent>
<cffunction name="formatDateString" output="false">
  <cfargument name="startMonth" required="true">
  <cfargument name="startDay" required="true">
  <cfargument name="endMonth" required="true">
  <cfargument name="endDay" required="true">
  <cfset var returnDate = ''>
  <cfif startMonth EQ endMonth>
    <cfset returnDate = startMonth&'<br/>'&startDay&'-'&endDay>
  <cfelse>
    <cfset returnDate = startMonth&' '&startDay&'-<br/>'&endMonth&' '&endDay>
  </cfif>
  <cfreturn returnDate>
</cffunction>
</cfsilent>
