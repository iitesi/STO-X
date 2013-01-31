<br /><br />
<div id="filterbar">
	<div>
		<div class="filterheader">Filter By</div>
		<button id="btnHotelChain">Hotel Chain</button>
		<button id="btnHotelAmenities">Amenities</button>
		<input type="checkbox" id="Policy" name="Policy"> <label for="Policy">In Policy</label>
	</div>
</div>
<cfoutput>
	<cfset arraysort(session.searches[rc.SearchID].stHotelChains,'text') />
	<div id="HotelDialog" class="popup">
		<div class="popup-hotel">
			<div class="region">
				<cfloop array="#session.searches[rc.SearchID].stHotelChains#" index="Chain">
					<div class="checkbox">
						<input id="HotelChain#Chain#" type="checkbox" name="HotelChain#Chain#" value="#Chain#" checked="checked" onclick="filterhotel();">
						<label for="HotelChain#Chain#">#StructKeyExists(application.stHotelVendors,Chain) ? application.stHotelVendors[Chain] : 'No Chain found'#</label>
					</div>
				</cfloop>
			</div>
		</div>
	</div>
	<div id="AmenityDialog" class="popup">
		<div class="popup-hotel">
			<div class="region">
				<cfloop array="#session.searches[rc.SearchID].stAmenities#" index="Amenity">
					<div class="checkbox">
						<input id="#Amenity#" type="checkbox" name="HotelAmenity#Amenity#" value="#Amenity#" onclick="filterhotel();">
						<label for="#Amenity#">#application.stAmenities[Amenity]#</label>
					</div>
				</cfloop>
			</div>
		</div>
	</div>
</cfoutput>