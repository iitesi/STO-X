<cfset stAmenities = session.searches[url.SearchID].stHotels[PropertyID].Amenities />

<cfoutput>
	<div class="roundall" style="padding:10px;background-color:##FFFFFF; display:table;font-size:11px;width:600px">
		<table width="600px">
		<cfset count = 0 />
		<cfloop list="#StructKeyList(stAmenities)#" index="Amenity">
			<cfset count++ />
			<cfif count % 4 EQ 1>
				<tr>
			</cfif>
				<td>#application.stAmenities[Amenity]#</td>
			<cfif count % 4 EQ 0>
				</tr>
			</cfif>			
		</cfloop>
		</table>
	</div>
</cfoutput>