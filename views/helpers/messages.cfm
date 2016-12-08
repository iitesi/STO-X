<cfset messages = rc.message.getAllMessages()>

<cfif messages.recordCount GT 0>
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
