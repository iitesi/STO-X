<cfset PropertyID = url.PropertyID />
<cfset stHotel = session.searches[url.SearchID].stHotels[PropertyID] />
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

<cfset HotelDetails = application.objHotelDetails.doHotelDetails(url.SearchID,PropertyID,HotelChain,RoomRatePlanType) />

<cfoutput>
	<div class="roundall" style="padding:10px;background-color:##FFFFFF; display:table;font-size:11px;width:600px">
		<table width="600px">
		<cfif Len(Trim(HotelDetails.CheckIn))>
			<tr>
				<td><strong>Check In</strong> - #HotelDetails.CheckIn#</td>
			</tr>			
		</cfif>
		<cfif Len(Trim(HotelDetails.CheckOut))>
			<tr>
				<td><strong>Check Out</strong> - #HotelDetails.CheckOut#</td>
			</tr>
		</cfif>
		<tr>
			<td><strong>Details</strong> - #replace(HotelDetails.Details,'|',' ','all')#</td>
		</tr>
		</table>
	</div>
</cfoutput>