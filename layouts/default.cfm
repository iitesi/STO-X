<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <title>STO .:. The New Generation of Corporate Online Booking</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="">
        <meta name="author" content="">



<link href="//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.2/css/bootstrap-combined.min.css" rel="stylesheet">
<script src="//code.jquery.com/jquery-1.9.1.min.js"></script>
<script src="//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.2/js/bootstrap.min.js"></script>


    <style type="text/css">
      body {
        padding-top: 60px;
        padding-bottom: 40px;
      }
    </style>


        <script src="http://ecn.dev.virtualearth.net/mapcontrol/mapcontrol.ashx?v=7.0&mkt=en-us" charset="UTF-8" type="text/javascript"></script>


        <script src="assets/js/hotel/hotel.js"></script>
        <script src="assets/js/angular.min.js"></script>
        <script src="assets/js/angular-resource.min.js"></script>
        <script src="assets/js/hotel/services.js"></script>
        <script src="assets/js/hotel/controllers.js"></script>
        <script src="assets/js/hotel/app.js" />
        <script src="assets/js/booking.js"></script><!---Custom--->
   </head>

    <body>
    <div class="navbar navbar-inverse navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container">
          <button type="button" class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="brand" href="#">The New Generation of Corporate Online Booking</a>
          <div class="nav-collapse collapse">
            <cfoutput>#View('main/navigation')#</cfoutput>
          </div><!--/.nav-collapse -->
        </div>
      </div>
    </div>



    <div id="main-wrapper" class="wide">

	    <header id="main-header">

	        <div id="header-top">
	            <div class="container">
	                <div class="sixteen columns">

	                    <div id="logo-container">
	                        <div id="logo-center"><!---logo here--->
	                        </div>
	                    </div>

	                    <div class="tagline">The New Generation of Corporate Online Booking</div>


	                </div>
	            </div>
	        </div>

	        <div id="header-bottom">
	            <div class="container">
	                <div class="sixteen columns">
	                    <ul class="breadcrumb">
		                    <cfoutput>#View('air/breadcrumbs')#</cfoutput>
	                    </ul>
	                </div>
	            </div>
	        </div>
	    </header>

	    <section id="main-content">
		    <div class="container">
				<cfoutput>#body#</cfoutput>
			</div>
	    </section>

	    <footer id="footer">

	        <div id="footer-top">
	            <div class="container">
					<cfoutput>
						#View('main/policy')#
						#View('main/unusedtickets')#
					</cfoutput>
	            </div>
	        </div>

	        <div id="footer-bottom">
	            <div class="container">
	                <div class="eight columns">
	                    Copyright Short's Travel Management <cfoutput>#Year(Now())#</cfoutput>. All Rights Reserved.
	                </div>
	            </div>
	        </div>

	    </footer>

    </div>

  </body>
</html>