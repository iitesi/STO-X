<style type="text/css">
.roundtrip {
	overflow: hidden;
	text-align: center;
	white-space: nowrap;
	width: 100%;
	margin: 0px auto;
}
.roundtrip .grouptab {
	-moz-border-bottom-colors: none;
	-moz-border-left-colors: none;
	-moz-border-right-colors: none;
	-moz-border-top-colors: none;
	background-color: #F4F0F0;
	border-color: #E0D6D6 -moz-use-text-color;
	border-image: none;
	border-style: solid none;
	border-width: 1px medium;
	color: #2E76CF;
	cursor: pointer;
	display: inline-block;
	font-weight: bold;
	height: 20px;
	line-height: 20px;
	margin: 10px 0 10px 0;
	padding: 5px 40px 5px 40px;
	position: relative;
	text-align: left;
}
.roundtrip .grouptab.first {
	border-left: 1px solid #E0D6D6;
	border-right: 1px solid #E0D6D6;
	border-top-left-radius:15px;
	border-bottom-left-radius:15px;
}
.roundtrip .grouptab.last {
	border-top-right-radius:15px;
	border-bottom-right-radius:15px;
	border-right: 1px solid #E0D6D6;
	border-left: 1px solid #E0D6D6;
}
.roundtrip .grouptab.selected {
	background-color: #FCF9D7;
	color: #333333;
}
</style>

<cfoutput>
	<div class="roundtrip">
		<cfset nCount = ArrayLen(StructKeyArray(session.searches[rc.nSearchID].stLegs))-1>
		<cfloop collection="#session.searches[rc.nSearchID].stLegs#" item="nLeg">
			<a href="#buildURL('air.availability?Search_ID=#rc.nSearchID#&Group=#nLeg#')#">
				<div class="grouptab <cfif nLeg EQ 0>first</cfif> <cfif nLeg EQ nCount>last</cfif> <cfif rc.nGroup EQ nLeg>selected</cfif>">
					<cfif NOT StructIsEmpty(session.searches[rc.nSearchID].stSelected[nLeg])>
						<img src="assets/img/checkmark.png">
					</cfif>
					#session.searches[rc.nSearchID].stLegs[nLeg]#
				</div>
			</a>
		</cfloop>
	</div>
	<ul class="smallnav">
		<li class="main">Display As
			<cfoutput>
				<ul>
					<li><a href="?action=air.availability&Search_ID=#rc.nSearchID#&nGroup=#rc.nGroup#">Badge</a></li>							
					<li><a href="?action=air.timeline&Search_ID=#rc.nSearchID#&nGroup=#rc.nGroup#">Timeline</a></li>							
				</ul>
			</cfoutput>
		</li>
	</ul>
</cfoutput>