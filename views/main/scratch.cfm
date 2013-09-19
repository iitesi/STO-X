<cfset es = application.fw.factory.getBean('EnvironmentService') />

<cfdump var="#es.getCurrentServerName()#"/>
<cfdump var="#es.getLocalServerNames()#"/>
<cfdump var="#es.getQAServerNames()#"/>
<cfdump var="#es.getbetaServerNames()#"/>
<cfdump var="#es.getProdBetaNames()#"/>
<cfdump var="#es.getCurrentEnvironment()#"/>
<cfdump var="#es.getAssetURL()#"/>
<cfdump var="#es.getSettings()#"/>