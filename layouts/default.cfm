<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>STO .:. The New Generation of Corporate Online Booking</title>
    <!---<link rel="stylesheet" href="assets/css/style.css" media="screen" />--->
</head>
<body class="home blog" id="com-html5doctor">
	<header role="banner">
		<div class="inner group">
			<a href="http://html5doctor.com" rel="home">
				<div>
					<hgroup>
						<h1>HTML5 Doctor</h1>
						<h2>Helping you implement HTML5 today</h2>
					</hgroup>
				</div>
			</a>
		
			<ul id="menu-top-nav" class="semantic-list">
				<li id="menu-item-3272" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-3272"><a href="http://html5doctor.com/about/">Air</a></li>
				<li id="menu-item-3275" class="menu-item menu-item-type-custom menu-item-object-custom menu-item-3275"><a href="http://feeds2.feedburner.com/html5doctor">Car</a></li>
				<li id="menu-item-3253" class="menu-item menu-item-type-custom menu-item-object-custom menu-item-3253"><a href="#">Hotel</a></li>
			</ul>
	
		    <nav>
				<ul id="menu-main_nav" class="">
					<cfoutput>
						<li id="menu-item-3297" class="menu-item menu-item-type-custom menu-item-object-custom current-menu-item current_page_item menu-item-3297"><a href="/">#session.searches[1].tab#</a></li>
					</cfoutput>
				</ul>
		    </nav>
		</div>
	</header>
	
	<div id="content" class="group" role="main">
		<article id="opener" class="group">
			<div class="main">
				<article class="post">
					<p><cfoutput>#body#</cfoutput></p>
				</article>
			</div>
		</article>
	</div>
	
	<footer role="contentinfo">
		<div class="inner">
	    	<p id="copyright">Short's Travel Management</p>
	    </div>
	</footer>
	
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"></script>
	<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js"></script>
			
</body>
</html>