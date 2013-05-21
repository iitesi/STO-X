<!---<cfset Hotel_Radiuses = '1,2,5,10,15,20,25' />
<cfset Hotel_Radius = rc.Filter.getHotel_Radius() />
<cfset Hotel_Search = rc.Filter.getHotel_Search() />
<div class="modifysearch">		
	<h3>Modify Search</h3>
	<cfoutput>
		<form method="post" action="#buildURL('hotel.search?SearchID=#rc.Filter.getSearchID()#')#" id="modifyhotelform">
			<input type="hidden" name="ModifySearch" value="LetsModify!" />
			<div id="filterhotelradius">
				<p>
					<label for="Hotel_Radius">Hotels within</label>
					<select name="Hotel_Radius" id="Hotel_Radius">
						<cfloop list="#Hotel_Radiuses#" index="Radius">
							<option value="#Radius#" <cfif Hotel_Radius EQ Radius>selected="selected"</cfif>>#Radius#</option>	
						</cfloop>
					</select>
				</p>
				<p>
					<label for="Hotel_Radius">miles of</label>
					<select name="Hotel_Search" id="Hotel_Search" onChange="stohotel();">
					<option value="Airport" <cfif Hotel_Search EQ 'Airport'>selected="selected"</cfif>>an airport</option>
					<option value="City" <cfif Hotel_Search EQ 'City'>selected="selected"</cfif>>a landmark</option>
					<option value="Address" <cfif Hotel_Search EQ 'Address'>selected="selected"</cfif>>an address</option>
					<!--- <cfif rc.offices.RecordCount>
						<option value="Office" <cfif Hotel_Search EQ 'Office'>selected="selected"</cfif>>an office or venue</option>
					</cfif> --->
					</select>
				</p>
			</div>
			<div id="filterhotelairport" <cfif Hotel_Search NEQ 'Airport'>class="hide"</cfif>>
				<p>
					<label for="Hotel_Airport">Airport</label>
					<input type="text" name="Hotel_Airport" id="Hotel_Airport" size="15" value="#rc.Filter.getHotel_Airport()#">
				</p>
			</div>
			<div id="filterhotellandmark" <cfif Hotel_Search NEQ 'City'>class="hide"</cfif>>
				<p>
					<label for="Hotel_Landmark">Landmark</label>
					<input type="text" name="Hotel_Landmark" id="Hotel_Landmark" size="15" value="#rc.Filter.getHotel_Landmark()#">
				</p>
			</div>
			<div id="filterhoteladdress" <cfif Hotel_Search NEQ 'Address'>class="hide"</cfif>>
				<p>
					<label for="Hotel_Address">Address</label>
					<input type="text" name="Hotel_Address" id="Hotel_Address" size="15" value="#rc.Filter.getHotel_Address()#">
				</p>
				<p>
					<label for="Hotel_City">City</label>
					<input type="text" name="Hotel_City" id="Hotel_City" size="15" value="#rc.Filter.getHotel_City()#">
				</p>
				<p>
					<cfset States = StructSort(application.stStates,'text')>
					<label for="Hotel_State">State</label>
					<select name="Hotel_State" id="Hotel_State" style="width:100px;">
						<option value=""></option>
						<cfloop collection="#States#" index="Code">
							<option value="#States[Code]#" <cfif rc.Filter.getHotel_State() EQ States[Code]>selected="selected"</cfif>>#States[Code]#</option>
						</cfloop>
					</select>
				</p>
				<p>
					<label for="Hotel_Zip">Zip Code</label>
					<input type="text" name="Hotel_Zip" id="Hotel_Zip" size="6" maxlength="10" value="#rc.Filter.getHotel_Zip()#">
				</p>
				<!--- <p>
					<label for="Hotel_Country">Country</label>
					<select name="Hotel_Country" id="Hotel_Country">
					<option value=""></option>
					<cfloop query="rc.countries">
						<option value="#rc.countries.Country_Code#" <cfif rc.Filter.getHotel_Country() EQ rc.countries.Country_Code>selected="selected"</cfif>>#rc.countries.Country_Code#</option>
					</cfloop>
					</select>
				</p> --->
			</div>
			<!--- <div id="filterhoteloffice" <cfif Hotel_Search NEQ 'Office'>class="hide"</cfif>>
				<label>Office or Venue</label>
				<select name="Office_ID" id="Office_ID">
				<cfloop query="rc.offices">
					<option value="#rc.offices.Office_ID#" <cfif rc.searchhotel.Office_ID EQ rc.offices.Office_ID>selected="selected"</cfif>>#Office_Name#</option>
				</cfloop>
				</select>
			</div> --->
			<div>
				<p>
					<label>Check In</label>
					<input name="CheckIn_Date" id="CheckIn_Date" size="10" value="#DateFormat(rc.Filter.getCheckIn_Date(), 'm/d/yyyy')#">
				</p>
			</div>
			<div>
				<p>
					<label>Check Out</label>
					<input name="CheckOut_Date" id="CheckOut_Date" size="10" value="#DateFormat(rc.Filter.getCheckOut_Date(), 'm/d/yyyy')#">
				</p>
			</div>
			<br clear="all">
			<div id="modifybutton" class="button-wrapper">
				<a onClick="submitForm('modifyhotelform', 'modifybutton', 'Searching...');" class="button"><span>Modify Search</span></a>
			</div>
			<br clear="all">
			<br>
		</form>
	</div>
</cfoutput>--->

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
						<!---<cfloop array="#session.searches[rc.SearchID].stHotelChains#" index="Chain">
							<li>
								<input id="HotelChain#Chain#" type="checkbox" name="HotelChain#Chain#" value="#Chain#" checked="checked" onclick="filterhotel();">
								<label for="HotelChain#Chain#">#StructKeyExists(application.stHotelVendors,Chain) ? application.stHotelVendors[Chain] : 'No Chain found'#</label>
							</li>
						</cfloop>--->
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