<style type="text/css">
.roundtrip {
	overflow: hidden;
	text-align: center;
	white-space: nowrap;
	width: 50%;
	margin: 0px auto;
}
.roundtrip .grouptab {
	-moz-border-bottom-colors: none;
	-moz-border-left-colors: none;
	-moz-border-right-colors: none;
	-moz-border-top-colors: none;
	background-color: #EDF3FE;
	border-color: #B7CFDF -moz-use-text-color;
	border-image: none;
	border-style: solid none;
	border-width: 1px medium;
	color: #92A9B8;
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
	border-left: 1px solid #B7CFDF;
	border-radius: 15px 0 0 15px;
}
.roundtrip .grouptab.last {
	border-radius: 0 15px 15px 0;
	border-right: 1px solid #B7CFDF;
}
.roundtrip .grouptab.selected {
	background-color: #FCF9D7;
	color: #333333;
}
</style>
<cfoutput>
	<div class="roundtrip">
		<cfset cnt = 0>
		<cfloop array="#session.searches[rc.nSearchID].Legs#" index="nLeg">
			<cfset classes = ''>
			<cfset cnt++>
			<cfif cnt EQ 1>
				<cfset classes = ListAppend(classes, 'first', ' ')>
				<cfset classes = ListAppend(classes, 'selected', ' ')>
			</cfif>
			<cfif cnt EQ ArrayLen(session.searches[rc.nSearchID].Legs)>
				<cfset classes = ListAppend(classes, 'last', ' ')>
			</cfif>
			<div class="grouptab #classes#">
				<a href="#buildURL('air.availability?Search_ID=#rc.nSearchID#&Group=#cnt-1#')#">#nLeg#</a>
			</div>
		</cfloop>
	</div>
</cfoutput>