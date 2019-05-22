<cfcookie name="releasenotes" expires="never" value="#application.releaseVersion#"/>
<div class="container-fluid" id="Main">
	<br><br>
	<div class="row">
		<div class="col-md-10 col-md-offset-1">
			<div class="panel panel-default">
				<div class="panel-heading">
					<h1 class="panel-title">Release Notes</h1>
				</div>
				<div class="panel-body" style="padding:25px;">
					<cfoutput>
						<p>
							<div style="padding:5px 0 0 0;font-size:13px;white-space:normal;word-wrap:break-word;">
								<h3>5/21/2019<h3>
                                <ul>
                                    <li>Fixed issue with seat assignments lost on purchase page when form validation fails</li>
									<li>Added retry logic to async seat map calls to handle intermittent uAPI call failures</li>
									<li>Added better static asset cache controls to ensure new features are seen without having to clear browser cache</li>
                                </ul>
							</div>
						</p>
						<p>
							<div style="padding:5px 0 0 0;font-size:13px;white-space:normal;word-wrap:break-word;">
								<h3>5/20/2019<h3>
                                <ul>
                                    <li>Fixed issue booking for other profiled travelers and guest traveler</li>
                                    <li>Improved app state management for greater performance and stability</li>
                                    <li>Added Release Notes menu item with <sup style="color:green;"><i>New!</i></sup> indicator for unread content</i>
                                </ul>
							</div>
						</p>
                        <p>
							<div style="padding:5px 0 0 0;font-size:13px;white-space:normal;word-wrap:break-word;">
								<h3>5/19/2019<h3>
                                <ul>
                                    <li>Added cabin class specific Seat Map selector for seat assignments on purchase page</li>
                                    <li>Auto-complete feature on the traveler selector when the list is greater than 100 (arranger and admin users)</li>
                                    <li>Highlighted airport codes when arrival airport on outbound leg is different than departure airport on return leg</i>
                                    <li>Prevent chrome autofill from putting saved username info in the Known Traveler field on the Purchase page</li>
                                    <li>New header and footer styles in the main app layout</i>
                                </ul>
							</div>
						</p>
					</cfoutput>
				</div>
			</div>
		</div>
	</div>
</div>