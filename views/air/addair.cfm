<cfsilent>
	<cfsavecontent variable="filterHeader">
		<script type='text/javascript' src='assets/js/air/filter.js'></script>
		<script>
			$(document).ready(function(){
				var frameSrc = $(searchModalButton).attr("data-framesrc");
				$("iframe").attr("src",frameSrc);
				$("#searchModal").modal("show");
			});
		</script>
	</cfsavecontent>
	<cfhtmlhead text="#filterHeader#" />
	<cfif structKeyExists(rc, "filter") AND rc.filter.getPassthrough() EQ 1 AND len(trim(rc.filter.getWidgetUrl()))>
		<cfset frameSrc = (cgi.https EQ 'on' ? 'https' : 'http')&'://'&cgi.Server_Name&'/search/index.cfm?'&rc.filter.getWidgetUrl()&'&token=#session.cookieToken#&date=#session.cookieDate#' />
	<cfelse>
		<cfset frameSrc = application.searchWidgetURL & "?acctid=#session.acctID#&userID=#session.userID#&token=#session.cookieToken#&date=#session.cookieDate#"/>
	</cfif>
</cfsilent>
<div class="container">
	<h1>No Flights Returned</h1>
	<p>You have not yet specified your air search criteria.</p>
	<p>Please <cfoutput><a href="##" id="searchModalButton" class="searchModalButton" data-framesrc="#frameSrc#&amp;searchid=#rc.searchID#&amp;requery=true" title="Start a new search">change your search</a></cfoutput> and try again.</p>
	<br /><br /><br /><br /><br /><br />
	<cfoutput>#View('modal/search')#</cfoutput>
</div>