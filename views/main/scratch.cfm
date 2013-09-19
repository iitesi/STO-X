<cfset es = application.fw.factory.getBean('EnvironmentService') />

<cfdump var="#es.getCurrentEnvironment()#"/>
<cfdump var="#es.getAssetURL()#"/>
<cfdump var="#es.getSettings()#"/>