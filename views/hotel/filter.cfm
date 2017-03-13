

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
						<li>
							<input id="HotelChain1" type="checkbox" name="HotelChain1" value="HH" checked="checked">
							<label for="HotelChain1">Hilton</label>
						</li>
						<li>
							<input id="HotelChain2" type="checkbox" name="HotelChain2" value="HY" checked="checked">
							<label for="HotelChain2">Hyatt</label>
						</li>
						<li>
							<input id="HotelChain3" type="checkbox" name="HotelChain3" value="MC" checked="checked">
							<label for="HotelChain3">Marriott</label>
						</li>
					</ul>
				</cfoutput>
			</li>
			<li>
				<input type="checkbox" id="HotelAmenities" name="HotelAmenities"> <label for="HotelAmenities">Amenities</label>
				<cfoutput>
					<ul>
						<!---<cfloop array="#session.searches[rc.SearchID].stAmenities#" index="Amenity">
							<li>
								<input id="#Amenity#" type="checkbox" name="HotelAmenity#Amenity#" value="#Amenity#" onclick="filterhotel();">
								<label for="#Amenity#">#application.stAmenities[Amenity]#</label>
							</li>
						</cfloop>--->
					</ul>
				</cfoutput>
			</li>
			<input type="checkbox" id="Policy" name="Policy"> <label for="Policy">In Policy</label>
			<input type="checkbox" id="SoldOut" name="SoldOut"> <label for="SoldOut">No Sold Outs</label>
		</td>
	</tr>
	</table>
</ul>
