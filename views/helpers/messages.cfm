<cfset messages = rc.message.getAllMessages()>

<cfif messages.recordCount GT 0>
	<cfoutput query="messages" group="type">
		<cfset typeClass="alert-success" />
		<cfif type IS "error">
			<cfset typeClass="alert-error" />
		</cfif>

		<div id="usermessage" class="alert #typeClass#">
			#message#
			<button type="button" class="closewell close pull-right" title="Close filters"><i class="icon-remove"></i></button>
		</div>
	</cfoutput>
</cfif>