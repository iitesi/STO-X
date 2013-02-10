<cfset arraysort(session.searches[rc.SearchID].stHotelChains,'text') />
<ul id="filter">
	<table>
	<tr>
		<td>
			<div class="filterheader">Filter By</h2>
		</td>
		<td>
			<li>
				<input type="checkbox" id="HotelChains" name="HotelChains"> <label for="HotelChains">Hotel Chain</label>
				<cfoutput>
					<ul>
						<cfloop array="#session.searches[rc.SearchID].stHotelChains#" index="Chain">
							<li>
								<input id="HotelChain#Chain#" type="checkbox" name="HotelChain#Chain#" value="#Chain#" checked="checked" onclick="filterhotel();">
								<label for="HotelChain#Chain#">#StructKeyExists(application.stHotelVendors,Chain) ? application.stHotelVendors[Chain] : 'No Chain found'#</label>
							</li>
						</cfloop>
					</ul>
				</cfoutput>
			</li>
			<li>
				<input type="checkbox" id="HotelAmenities" name="HotelAmenities"> <label for="HotelAmenities">Amenities</label>
				<cfoutput>
					<ul>
						<cfloop array="#session.searches[rc.SearchID].stAmenities#" index="Amenity">
							<li>
								<input id="#Amenity#" type="checkbox" name="HotelAmenity#Amenity#" value="#Amenity#" onclick="filterhotel();">
								<label for="#Amenity#">#application.stAmenities[Amenity]#</label>
							</li>
						</cfloop>
					</ul>
				</cfoutput>
			</li>
			<input type="checkbox" id="Policy" name="Policy"> <label for="Policy">In Policy</label>
			<input type="checkbox" id="SoldOut" name="SoldOut"> <label for="SoldOut">No Sold Outs</label>
		</td>
	</tr>
	</table>
</ul>