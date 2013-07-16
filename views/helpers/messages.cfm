<cfset messages = rc.message.getAllMessages()>

<cfif messages.recordCount GT 0>
	<cfoutput query="messages" group="type">
		<cfset typeClass="alert-success" />
		<cfif type IS "error">
			<cfset typeClass="alert-error" />
		</cfif>

		<div id="usermessage" class="alert #typeClass#">
		USER MSG: 	#message#
			<button type="button" class="closemsg close pull-right" title="Close message"><i class="icon-remove"></i></button>
		</div>
	</cfoutput>
</cfif>