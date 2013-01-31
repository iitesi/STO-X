<cfif cgi.SCRIPT_NAME DOES NOT CONTAIN '.cfc'>
    <!DOCTYPE html>
    <!--[if lt IE 7]> <html class="lt-ie9 lt-ie8 lt-ie7" lang="en"> <![endif]-->
    <!--[if IE 7]>    <html class="lt-ie9 lt-ie8" lang="en"> <![endif]-->
    <!--[if IE 8]>    <html class="lt-ie9" lang="en"> <![endif]-->
    <!--[if gt IE 8]><!--><html lang="en"><!--<![endif]-->

    <head>
        <meta charset="utf-8">

        <title>STO .:. The New Generation of Corporate Online Booking</title>

        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="">
        <meta name="author" content="">

        <!-- Le Styles -->
        <link href="assets/css/bootstrap.min.css" rel="stylesheet">
        <link href="assets/css/skeleton.css" rel="stylesheet">
        <link href="assets/css/layout.css" rel="stylesheet">
        <link href="assets/css/style.css" rel="stylesheet">
        <link href="assets/css/smoothness/jquery-ui-1.9.2.custom.css" rel="stylesheet">

        <!-- Le Fonts -->
        <link href="http://fonts.googleapis.com/css?family=Open+Sans:400italic,700italic,400,700" rel="stylesheet">
        <link href="assets/css/fonts/glyphicons/style.css" rel="stylesheet">

        <!-- Le HTML5 shim, for IE6-8 support of HTML5 elements -->
        <!--[if lt IE 9]>
		<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
        <![endif]-->
        <!-- Required Scripts -->
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
        <script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/jquery-ui.min.js"></script>
        <script src="assets/js/jquery.plugins.min.js"></script>
        <script src="assets/js/bootstrap.min.js"></script>
        <script src="assets/js/booking.js"></script><!---Custom--->
        <script src="assets/js/jqModal.js"></script><!---Overlay--->
    </head>

    <body>

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

	                <cfoutput>#View('main/navigation')#</cfoutput>
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

                <div class="one-third column">
					<h3>Air Policy</h3>
					<ul>
						<cfoutput>
							<cfif rc.Policy.Policy_AirLowRule EQ 1>
						        <li>Book lowest fare<cfif rc.Policy.Policy_AirLowPad GT 5> within $#NumberFormat(rc.Policy.Policy_AirLowPad)#</cfif></li>
							</cfif>
							<cfif rc.Policy.Policy_AirMaxRule EQ 1>
	                            <li>Max fare allowed $#NumberFormat(rc.Policy.Policy_AirMaxTotal)#</li>
							</cfif>
							<cfif rc.Policy.Policy_AirAdvRule EQ 1>
	                            <li>Advance purchase of #rc.Policy.Policy_AirAdv# day<cfif rc.Policy.Policy_AirAdv GT 1>s</cfif></li>
							</cfif>
							<cfif rc.Policy.Policy_AirRefDisp EQ 1>
	                            <li>Book refundable tickets</li>
							</cfif>
							<cfif rc.Policy.Policy_AirNonRefDisp EQ 1>
	                            <li>Book non refundable tickets</li>
							</cfif>
							<cfif rc.Policy.Policy_AirPrefRule EQ 1>
								<cfif rc.Policy.Policy_AirPrefDisp EQ 1>
	                                <li>Must book preferred carrier</li>
								<cfelse>
	                                <li>Book preferred carrier</li>
								</cfif>
							</cfif>
						</cfoutput>
				    </ul>
                    <h3>Hotel Policy</h3>
                    <ul>
						<cfoutput>
							<cfif rc.Policy.Policy_HotelMaxRule EQ 1>
                                <li>Max rate allowed $#NumberFormat(rc.Policy.Policy_HotelMaxRate)#</li>
							</cfif>
							<cfif rc.Policy.Policy_HotelPrefRule EQ 1>
                                <li>Book preferred chain</li>
							</cfif>
						</cfoutput>
					</ul>
                    <h3>Car Policy</h3>
                    <ul>
						<cfoutput>
							<cfif rc.Policy.Policy_CarMaxRule EQ 1>
                                <li>Max daily rate allowed $#NumberFormat(rc.Policy.Policy_CarMaxRate)#</li>
							</cfif>
							<cfif rc.Policy.Policy_CarTypeRule EQ 1>
                                <li>Book specific car types</li>
							</cfif>
							<cfif rc.Policy.Policy_CarPrefRule EQ 1>
								<cfif rc.Policy.Policy_CarPrefDisp EQ 1>
                                    <li>Must book preferred vendor</li>
								<cfelse>
                                    <li>Book preferred vendor</li>
								</cfif>
							</cfif>
						</cfoutput>
					</ul>
                </div>

                <div class="one-third column">
                    <h3>Unused Tickets</h3>
					<script type="text/javascript">
                    getUnusedTickets(3605,1);
					</script>
	                <div id="unusedtickets"></div>
                </div>

                <div class="one-third column">
                    <h3>Photostream</h3>
                </div>

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
</cfif>