<cfinvoke component="services.hotelphotos" method="doHotelPhotoGallery" nSearchID="#url.Search_ID#" nHotelCode="#PropertyID#" sHotelChain="#HotelChain#" />

<cfset aHotelPhotos = session.searches[url.Search_ID].stHotels[PropertyID].aHotelPhotos />

<cfoutput>
	<div class="roundall" style="padding:10px;background-color:##FFFFFF; display:table;font-size:11px;width:600px">
		<table width="600px">
		<cfset count = 0 />
		<cfloop array="#aHotelPhotos#" index="Photo">
			<cfset count++ />
			<cfif count % 4 EQ 1>
				<tr>
			</cfif>
				<td><img src="#Photo#" /></td>
			<cfif count % 4 EQ 0>
				</tr>
			</cfif>			
		</cfloop>
		</table>
	</div>
</cfoutput>