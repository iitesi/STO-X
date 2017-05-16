<cfset messages = rc.message.getAllMessages()>
<cfparam name="rc.priceQuotedError" default="0">
<cfif messages.recordCount GT 0 or 1 eq 1>
	<cfif rc.priceQuotedError eq 1>
		<div id="reservationMessage" class="alert alert-success bg-success" >
			<cfoutput>#messages.message#</cfoutput>
			<input type="submit" name="trigger" id="purchaseButton" class="btn btn-primary" style="margin-left: 20px;" value="CONFIRM THIS PRICE"> 
		</div>
	<cfelse>
		<cfoutput query="messages" group="type">
			<cfset typeClass="alert-success" />
			<cfif type IS "error">
				<cfif message IS "The rules for this fare have changed - this fare is nonrefundable.">
					<cfset typeClass="bg-danger alert-error-larger" />
				<cfelse>
					<cfset typeClass="bg-danger" />
				</cfif>
			</cfif>

			<div id="usermessage" class="alert #typeClass#">
				#replace(message, ',', '<li>', 'ALL')#
				<button type="button" class="closemsg close pull-right" title="Close message"><i class="icon-remove"></i></button>
			</div>
		</cfoutput>
	</cfif>
</cfif>
