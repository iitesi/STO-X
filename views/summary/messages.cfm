<cfoutput>
<cfif StructKeyExists(rc,'TravelMessages')>
  <cfloop array="#rc.TravelMessages#" index="local.msg">
    <div class="travelMessage">
      #local.msg.getHTMLText()#
    </div>
  </cfloop>
</cfif>
</cfoutput>
