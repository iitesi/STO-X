Need to write/pull information from hoteldetails.cfc
<cfset PropertyID = url.PropertyID />
<cfset stHotel = session.searches[url.Search_ID].stHotels[PropertyID] />
<cfset HotelChain = stHotel.HotelChain />
<cfset RoomRatePlanType = Len(Trim(url.RoomRatePlanType)) ? url.RoomRatePlanType : '' />
<cfif NOT Len(Trim(RoomRatePlanType))  AND structKeyExists(stHotel,'Rooms')>
	<cfloop list="#StructKeyList(stHotel.Rooms,'|')#" index="OneRoom" delimiters="|">
		<cfif Len(Trim(stHotel.Rooms[OneRoom].RoomRatePlanType))>
			<cfset RoomRatePlanType = stHotel.Rooms[OneRoom].RoomRatePlanType />
			<cfbreak />
		</cfif>
	</cfloop>		
</cfif>

<cfdump eval=PropertyID>
<cfdump eval=HotelChain>
<cfdump eval=RoomRatePlanType>
<cfinvoke component="services.hoteldetails" method="doHotelDetails" nSearchID="#url.Search_ID#" nHotelCode="#PropertyID#" sHotelChain="#HotelChain#" sRatePlanType="#RoomRatePlanType#" returnvariable="getHotelDetails">



<!---
 	if (type == 'details') {
		var list = 'ServiceDetail,FacilityDetail,RoomDetail,RecreationDetail,CheckIn,CheckOut';
	}
	else if (type == 'area') {
		var list = 'HotelLocationDetail,DirectionDetail,AreaTransportationDetail';
	}
 --->



<cfset details = details(url.sHotel) />
<cffunction name="details" access="remote" returntype="any" returnformat="plain" output="false">
	<cfargument name="Property_ID" required="yes" type="numeric">
	<cfargument name="Depart_DateTime" required="yes" type="string">
	<cfargument name="list" required="yes" type="string">
	<cfargument name="type" required="yes" type="string">
	<cfargument name="callback" required="false" type="string">
	<cfargument name="PCC" default="#application.stAccounts[session.Acct_ID].PCC_Booking#" />
	
	<cfset local.Property_ID = arguments.Property_ID />
	<cfset local.PCC = arguments.PCC />

	<cfquery name="getHotelDetails" datasource="book">
	SELECT ServiceDetail,FacilityDetail,RoomDetail,RecreationDetail,CheckIn,CheckOut
	FROM lu_hotels
	WHERE Property_ID = <cfqueryparam value="#Property_ID#" cfsqltype="cf_sql_integer">
	AND #arguments.type#_DateTime > #CreateODBCDateTime(DateAdd('m', -1, Now()))#
	</cfquery>
	
	<cfif getHotelDetails.RecordCount LTE 0>
		<cfobject type="com" action="create" class="OBE.HotelDetail" name="HotelDetailObj" context="inproc">
		
		<cfset HotelDetailResults = HotelDetailObj.HotelDetail("ProHCM", "#PCC#", "#ToString(Property_ID)#", "#DateFormat(arguments.Depart_DateTime, 'mm/dd/yyyy')#", "")>
		
		<cfset variables.details = StructNew()>
		<cfloop list="#arguments.list#" index="i">		
			<cfset variables.details[variables.i] = Evaluate('HotelDetailObj.#variables.i#()')>
		</cfloop>
		
		<cfquery datasource="book">
		UPDATE lu_hotels
		SET <cfloop list="#arguments.list#" index="variables.i">		
				#variables.i# = <cfqueryparam value="#Left(variables.details[variables.i], 2000)#" cfsqltype="cf_sql_longvarchar">,
			</cfloop>
		#arguments.type#_DateTime = getDate()
		WHERE Property_ID = <cfqueryparam value="#Property_ID#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfquery name="getHotelDetails" datasource="book">
		SELECT #arguments.list#
		FROM lu_hotels
		WHERE Property_ID = <cfqueryparam value="#Property_ID#" cfsqltype="cf_sql_integer">
		</cfquery>
		
	</cfif>

	<cfset details = getHotelDetails />
		
	<cfreturn details />
</cffunction>



function hotelDetails(property_id, type) {
	if (type == 'details') {
		var list = 'ServiceDetail,FacilityDetail,RoomDetail,RecreationDetail,CheckIn,CheckOut';
	}
	else if (type == 'area') {
		var list = 'HotelLocationDetail,DirectionDetail,AreaTransportationDetail';
	}
	$.ajax({
		url:"https://www.shortstravel.com/bookrate.cfc?method=details",
		data:"PCC="+pcc+"&Property_ID="+property_id+"&Depart_DateTime="+depart_date+"&list="+list+"&type="+type,
		dataType: 'jsonp',
		crossDomain: true,
		beforeSend:function () {
			$( "#details" + property_id ).removeClass('refbuttonactive');
			$( "#rates" + property_id ).removeClass('refbuttonactive');
			$( "#amenities" + property_id ).removeClass('refbuttonactive');
			$( "#photos" + property_id ).removeClass('refbuttonactive');
			$( "#area" + property_id ).removeClass('refbuttonactive');
			$( "#" + type + property_id ).addClass('refbuttonactive');
			$( "#seerooms" + property_id ).show();
			$( "#hiderooms" + property_id ).hide();
			$( "#hotelrooms" + property_id).html('<div style="border-top:1px dashed gray;"></div><div style="width:100%;margin:0 auto; text-align:center;"><br><br><img src="'+serverurl+'/assets/img/ajax-loader.gif"><br>Gathering the most up to date information...</div>').show();
		},
		success:function(details) {
			var table = '<div style="border-top:1px dashed gray;"></div><div class="listtable">';
			$.each(details.DATA, function(key, val) {
				if (type == 'details') {
					table += '<div class="listrow"><strong>HOTEL DETAILS</strong><a href="#" onClick="hideDetails(' + property_id + ');return false;" style="float:right;">close details</a><br><br></div>';
					table += '<div class="listrow" style="padding:5px;border-top:1px dashed gray;"><strong>Check In Time</strong>: ' + val[4] + '<br><br></div>';
					table += '<div class="listrow" style="padding:5px;border-top:1px dashed gray;"><strong>Check Out Time</strong>: ' + val[5] + '<br><br></div>';
					table += '<div class="listrow" style="padding:5px;border-top:1px dashed gray;"><strong>Service</strong>: ' + val[0] + '<br><br></div>';
					table += '<div class="listrow" style="padding:5px;border-top:1px dashed gray;"><strong>Facility</strong>: ' + val[1] + '<br><br></div>';
					table += '<div class="listrow" style="padding:5px;border-top:1px dashed gray;"><strong>Rooms</strong>: ' + val[2] + '<br><br></div>';
					table += '<div class="listrow" style="padding:5px;border-top:1px dashed gray;"><strong>Recreation</strong>: ' + val[3] + '<br><br></div>';
				}
				else if (type == 'area') {
					table += '<div class="listrow"><strong>AREA & LOCATION</strong><a href="#" onClick="hideDetails(' + property_id + ');return false;" style="float:right;">close details</a><br><br></div>';
					table += '<div class="listrow" style="padding:5px;border-top:1px dashed gray;"><strong>Hotel Location</strong>: ' + val[0] + '<br><br></div>';
					table += '<div class="listrow" style="padding:5px;border-top:1px dashed gray;"><strong>Directions</strong>: ' + val[1] + '<br><br></div>';
					table += '<div class="listrow" style="padding:5px;border-top:1px dashed gray;"><strong>Area Transportation</strong>: ' + val[2] + '<br><br></div>';
				}
			});
			table += '</div>';
			$( "#hotelrooms" + property_id).html(table).show();
		},
		error:function(test, tes, te) { 
			//console.log(te);
		}
	});
	return false;
}
<cfabort>