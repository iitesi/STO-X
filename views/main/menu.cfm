<div class="container-fluid" id="Main">
	<br><br>
	<div class="row">
		<div class="col-md-10 col-md-offset-1">
			<div class="panel panel-default">
				<div class="panel-heading">
					<h1 class="panel-title">Main Menu</h1>
				</div>
				<div class="panel-body" style="padding:25px;">
					<cfoutput>
						<div class="badge" onclick="window.location='?action=main.search'" style="cursor:pointer;padding:13px 15px 15px 15px;text-align:left;white-space:nowrap;">
							<table width="100%" cellspacing="0" cellpadding="0" align="center">
								<tr>
									<td valign="top" style="width:35px;">
										<button type="submit" class="btn btn-primary">
											<span class="glyphicon glyphicon-plane"></span>
										</button>
									</td>
									<td style="padding-left:10px;text-align:left;">
										<span style="display:inline-block;padding:0 0 5px 0;font-size:13px;font-weight:bold;color:##696969;white-space:normal;word-wrap:break-word;">Book a trip</span><br>
										<span style="display:inline-block;padding:0 0 0 0;font-size:11px;font-weight:normal;white-space:normal;word-wrap:break-word;">Air, hotel, and car reservations.</span>
									</td>
								</tr>
							</table>
						</div>
						<div class="badge"onclick="window.location='?action=main.trips'" style="cursor:pointer;padding:13px 15px 15px 15px;text-align:left;white-space:nowrap;">
							<table width="100%" cellspacing="0" cellpadding="0" align="center">
								<tr>
									<td valign="top" style="width:35px;">
										<button type="submit" class="btn btn-primary">
											<span class="glyphicon glyphicon-calendar"></span>
										</button>
									</td>
									<td style="padding-left:10px;text-align:left;">
										<span style="display:inline-block;padding:0 0 5px 0;font-size:13px;font-weight:bold;color:##696969;white-space:normal;word-wrap:break-word;">View my trips</span><br>
										<span style="display:inline-block;padding:0 0 0 0;font-size:11px;font-weight:normal;white-space:normal;word-wrap:break-word;">See your reservation details.</span>
									</td>
								</tr>
							</table>
						</div>
						<!--- STM-7280 STO and SSO account configurability --->
						<!--- TODO: This is to be part of the account configuration like the other hard-coded accID = 532 --->
						<!--- Per Steph we want this to pull from the policy information in the portal with checkbox to show in STO --->
						<cfif session.acctId eq 532>
							<a href="?action=dycom.policy" style="text-decoration:none;color:black;" target="_blank">
								<div class="badge" style="cursor:pointer;padding:13px 15px 15px 15px;text-align:left;white-space:nowrap;">
									<table width="100%" cellspacing="0" cellpadding="0" align="center">
										<tr>
											<td valign="top" style="width:35px;">
												<button type="submit" class="btn btn-primary">
													<span class="glyphicon glyphicon-info-sign"></span>
												</button>
											</td>
											<td style="padding-left:10px;text-align:left;">
												<span style="display:inline-block;padding:0 0 5px 0;font-size:13px;font-weight:bold;color:##696969;white-space:normal;word-wrap:break-word;">Policy Reminders</span><br>
												<span style="display:inline-block;padding:0 0 0 0;font-size:11px;font-weight:normal;white-space:normal;word-wrap:break-word;">Your travel policy documents.</span>
											</td>
										</tr>
									</table>
								</div>
							</a>
						</cfif>
						<div class="badge" onclick="window.location='?action=main.contact'" style="cursor:pointer;padding:15px 13px 15px 15px;text-align:left;white-space:nowrap;">
							<table width="100%" cellspacing="0" cellpadding="0" align="center">
								<tr>
									<td valign="top" style="width:35px;">
										<button type="submit" class="btn btn-primary">
											<span class="glyphicon glyphicon-user"></span>
										</button>
									</td>
									<td style="padding-left:10px;text-align:left;">
										<span style="display:inline-block;padding:0 0 5px 0;font-size:13px;font-weight:bold;color:##696969;white-space:normal;word-wrap:break-word;">Contact an agent</span><br>
										<span style="display:inline-block;padding:0 0 0 0;font-size:11px;font-weight:normal;white-space:normal;word-wrap:break-word;">Get in touch with Short's Travel.</span>
									</td>
								</tr>
							</table>
						</div>
						<div class="badge" onclick="window.location='?action=main.releasenotes'" style="cursor:pointer;padding:15px 13px 15px 15px;text-align:left;white-space:nowrap;">
							<table width="100%" cellspacing="0" cellpadding="0" align="center">
								<tr>
									<td valign="top" style="width:35px;">
										<button type="submit" class="btn btn-primary">
											<span class="glyphicon glyphicon-list"></span>
										</button>
									</td>
									<td style="padding-left:10px;text-align:left;">
										<span style="display:inline-block;padding:0 0 5px 0;font-size:13px;font-weight:bold;color:##696969;white-space:normal;word-wrap:break-word;">
											Release Notes
											<cfif !structKeyExists(cookie, "releasenotes") OR cookie.releasenotes NEQ application.releaseVersion>
												<sup style="color:green;"><i>New!</i></sup>
											</cfif>
										</span>
										<br>
										<span style="display:inline-block;padding:0 0 0 0;font-size:11px;font-weight:normal;white-space:normal;word-wrap:break-word;">Release notes and info about known issues.</span>
									</td>
								</tr>
							</table>
						</div>
					</cfoutput>
				</div>
			</div>
		</div>
	</div>
</div>