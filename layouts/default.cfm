<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>STO .:. The New Generation of Corporate Online Booking</title>
    <link rel="stylesheet" href="assets/css/reset.css" media="screen" />
	<link href='http://fonts.googleapis.com/css?family=Capriola|Karla|Chivo' rel='stylesheet' type='text/css'>
    <link rel="stylesheet" href="assets/css/style.css" media="screen" />
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"></script>
	<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js"></script>
	<script src="assets/js/booking.js"></script>
</head>

<body>
	
	<header id="header">
		<div class="inner group">
			<div>
				<hgroup>
					<cfoutput>
						<h1>#session.Username#</h1>
						<cfif session.searches[rc.Search_ID].BookingFor NEQ ''>
							<h2>Booking for #session.searches[rc.Search_ID].BookingFor#</h2>
						</cfif>
					</cfoutput>
				</hgroup>
			</div>
		
			<ul id="menu-top-nav">
				<li id="menu-item-3272" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-3272"><a href="http://html5doctor.com/about/">Air</a></li>
				<li id="menu-item-3275" class="menu-item menu-item-type-custom menu-item-object-custom menu-item-3275"><a href="http://feeds2.feedburner.com/html5doctor">Car</a></li>
				<li id="menu-item-3275" class="menu-item menu-item-type-custom menu-item-object-custom menu-item-3275"><a href="http://feeds2.feedburner.com/html5doctor">Hotel</a></li>
				<li id="menu-item-3253" class="menu-item menu-item-type-custom menu-item-object-custom menu-item-3253"><a href="#">Purchase</a></li>
				<cfoutput><h2>#rc.Search_ID#</h2></cfoutput>
			</ul>
	
		    <nav>
				<ul>
					<cfoutput>
						<li>
							<cfloop array="#StructKeyArray(session.searches)#" index="local.search">
								<a href="index.cfm?Search_ID=#rc.Search_ID#&action=air.lowfare">#session.searches[search].Heading#</a>
							</cfloop>
							<a href="/">New Search</a>
						</li>
					</cfoutput>
				</ul>
		    </nav>
		</div>
	</header>
	
	<div id="content" class="group">
		<p><cfoutput>#body#</cfoutput></p>
	</div>
	
	<footer role="contentinfo">
		<div class="inner">
			<p id="copyright">Short's Travel Management <cfoutput>#Year(Now())#</cfoutput></p>
		</div>
	</footer>
	
	<cfdump eval=session>
	
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"></script>
	<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js"></script>
			
</body>

</html>