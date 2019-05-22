<cfscript>
	session.AcctId = 0;
	session.UserId = 0;
	session.User = {};
	session.IsAuthorized = false;
	location("/booking/index.cfm?action=main.login",false);
</cfscript>
