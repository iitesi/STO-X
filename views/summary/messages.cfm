<cfoutput>
<cfif StructKeyExists(rc,'Messages')>
  <cfloop array="#rc.Messages#" index="local.msg">
    <div class="travelMessage">
      #local.msg.getHTMLText()#
    </div>
  </cfloop>
</cfif>
</cfoutput>
