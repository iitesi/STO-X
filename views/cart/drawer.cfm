<cfif structKeyExists(session, 'Searches')
    AND structKeyExists(rc, 'SearchId')
    AND structKeyExists(session.Searches, rc.SearchId)
    AND rc.action DOES NOT CONTAIN 'main'
    AND rc.action DOES NOT CONTAIN 'confirmation'>

    <script type="text/javascript">
        // $('#main-content').toggleClass('toggled');
    </script>

    <cfset rc.itinerary = session.searches[rc.searchID].stItinerary />
    <cfset rc.airSelected = (structKeyExists(rc.itinerary, 'Air') ? true : false) />
    <cfset rc.Air = (structKeyExists(rc.itinerary, 'Air') ? rc.itinerary.Air : '') />
    <cfset rc.hotelSelected = (structKeyExists(rc.itinerary, 'Hotel') ? true : false) />
    <cfset rc.Hotel = (structKeyExists(rc.itinerary, 'Hotel') ? rc.itinerary.Hotel : '') />
    <cfset rc.vehicleSelected = (structKeyExists(rc.itinerary, 'Vehicle') ? true : false) />
    <cfset rc.Vehicle = (structKeyExists(rc.itinerary, 'Vehicle') ? rc.itinerary.Vehicle : '') />

    <!--- Displaying the air, hotel, and car tabs based on whether the custom search widget allows for it. --->
    <cfif isDefined("rc.searchId") AND val(rc.searchId) AND structKeyExists(rc,"filter") AND rc.filter.getPassthrough() EQ 1 AND len(trim(rc.filter.getWidgetUrl()))>
        <cfloop list="#rc.filter.getWidgetUrl()#" delimiters="&" index="item">
            <cfif ListGetAt(item, 1, "=") IS "air">
                <cfset airValue = ListGetAt(item, 2, "=") />
            <cfelseif ListGetAt(item,1,"=") IS "hotel">
                <cfset hotelValue = ListGetAt(item, 2, "=") />
            <cfelseif ListGetAt(item,1,"=") IS "car">
                <cfset carValue = ListGetAt(item, 2, "=") />
            </cfif>
        </cfloop>
        <cfset showAirTab = yesNoFormat(airValue) />
        <!--- The default for hotel is yes/1/true. If not specified, must be displayed. --->
        <cfif len(hotelValue)>
            <cfset showHotelTab = yesNoFormat(hotelValue) />
        <cfelse>
            <cfset showHotelTab = 1 />
        </cfif>
        <cfset showCarTab = yesNoFormat(carValue) />
        <cfset showAirTab = (rc.Filter.getAir() IS TRUE ? 1 : 0) />
        <cfset showPurchaseTab = true/>
    <cfelseif isDefined("rc.searchId") AND val(rc.searchId) AND structKeyExists(session,"DepartmentPreferences")>
        <cfset showAirTab = ((rc.Filter.getAir() IS TRUE AND session.DepartmentPreferences.STOAir NEQ 0) ? 1 : 0) />
        <cfset showHotelTab = (((NOT rc.Filter.getAir() IS TRUE OR rc.Filter.getAirType() NEQ 'MD') AND session.DepartmentPreferences.STOHotel NEQ 0) ? 1 : 0) />
        <cfset showCarTab = (((NOT rc.Filter.getAir() IS TRUE OR rc.Filter.getAirType() NEQ 'MD') AND session.DepartmentPreferences.STOCar NEQ 0) ? 1 : 0) />
        <cfset showPurchaseTab = true/>
    <cfelse>
        <cfset showAirTab = false/>
        <cfset showHotelTab = false/>
        <cfset showCarTab = false/>
        <cfset showPurchaseTab = false/>
    </cfif>

    <cfset ordering = structNew()>
    <cfset maxAirFlights = 0>
    <cfif rc.airSelected>
        <cfloop collection="#session.searches[rc.searchId].stItinerary.Air#" item="Segment" index="i">
            <cfif NOT structIsEmpty(Segment)
                AND structKeyExists(Segment, 'DepartureTime')>
                <cfset ordering[i] = createODBCDateTime(Segment.DepartureTime)>
                <cfset maxAirFlights = i>
            </cfif>
        </cfloop>
    </cfif>
    <cfif rc.hotelSelected AND isDate(rc.filter.getCheckInDate())>
        <cfset ordering['Hotel'] = createDateTime(year(rc.filter.getCheckInDate()), month(rc.filter.getCheckInDate()), day(rc.filter.getCheckInDate()), 23, 59, 00)>
    </cfif>
    <cfif rc.vehicleSelected AND isDate(rc.Filter.getCarPickUpDateTime())>
        <cfset ordering['Car'] = createODBCDateTime(rc.Filter.getCarPickUpDateTime())>
    </cfif>
    <cfset itineraryOrder = structSort(ordering)>

    <cfset tripTotal = 0>
    <cfset tripCurrency = ''>

    <cfif rc.airSelected OR rc.hotelSelected OR rc.vehicleSelected>
        <cfset displayCart = true>
    <cfelse>
        <cfset displayCart = false>
    </cfif>

    <cfif structKeyExists(rc, 'Filter') AND IsObject(rc.Filter)>
        <button type="button" class="cart-open-icon is-closed" data-toggle="offcanvas">
            <i class="material-icons">shopping_cart</i>
        </button>

        <!-- Sidebar -->
        <nav class="navbar" id="sidebar-wrapper" role="navigation">
            <ul class="nav sidebar-nav container">
                <cfoutput>
                    <li class="sidebar-header">
                        <div class="row">
                            <div class="col-sm-10">Itinerary for</div>
                            <div class="col-sm-2">
                                <button type="button" class="cart-close-icon" data-toggle="offcanvas">
                                    <i class="material-icons">close</i>
                                </button>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-12">#rc.Filter.getProfileUsername()#</div>
                        </div>
                        <br>
                    </li>
                    <cfif displayCart>
                        <cfloop array="#itineraryOrder#" index="segment">
                            <cfif isNumeric(segment) AND showAirTab>
                                <!---Air--->
                                <cfif rc.airSelected>
                                    <cfloop collection="#rc.Air#" item="group" index="i">
                                        <cfif segment EQ i AND NOT structIsEmpty(group)>
    										<li>
    											<div class="row">
    												<div class="col-sm-12">
    													<a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Air&Group=#i#')#"><img class="carrierimg" src="assets/img/airlines/#group.CarrierCode#_sm.png" title="#application.stAirVendors[group.CarrierCode].Name#"></a><br>
    													#group.OriginAirportCode# - #group.DestinationAirportCode#<br>
    													#DateFormat(group.DepartureTime, 'DDD, MMM d, yyyy')#<br>
    													#TimeFormat(group.DepartureTime, 'h:mm tt')# - #TimeFormat(group.ArrivalTime, 'h:mm tt')#
                                                        <cfif structCount(rc.Air) EQ i+1
                                                            AND structKeyExists(rc.Air[0], 'TotalPrice')>
                                                            <br>
                                                            #numberFormat(rc.Air[0].TotalPrice, '____.__')#
                                                            <cfset tripTotal = tripTotal + rc.Air[0].TotalPrice>
                                                            <cfset tripCurrency = listAppend(tripCurrency, 'USD')>
                                                        </cfif>
                                            		</div>
    											</div>
    										</li>  
                                        </cfif>
                                    </cfloop>
                                </cfif>
                            </cfif>
                            <cfif segment EQ 'Hotel' AND rc.Filter.getHotel() AND showHotelTab>
                                <!---Hotel--->
                                <cfif rc.hotelSelected>
    								<li>
    									<div class="row">
    										<div class="col-sm-12">
    											<a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Hotel')#"><i class="material-icons">hotel</i></a><br>
    											#rc.Hotel.getPropertyName()#<br>
    											<a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Hotel')#" class="cart-icon"><i class="material-icons" style="font-size:15px;">edit</i></a>
    											<a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Hotel&Remove=1')#" class="cart-icon"><i class="material-icons" style="font-size:15px;">delete</i></a>
    											#DateFormat(rc.filter.getCheckInDate(), 'DDD, MMM d')# to #DateFormat(rc.filter.getCheckOutDate(), 'DDD, MMM d')#<br>
                                                <cfif rc.Hotel.getRooms()[1].getTotalForStay() GT 0>
                                                    <cfset currency = rc.Hotel.getRooms()[1].getTotalForStayCurrency()>
                                                    <cfset hotelTotal = rc.Hotel.getRooms()[1].getTotalForStay()>
                                                <cfelseif rc.Hotel.getRooms()[1].getBaseRate() GT 0>
                                                    <cfset currency = rc.Hotel.getRooms()[1].getBaseRateCurrency()>
                                                    <cfset hotelTotal = rc.Hotel.getRooms()[1].getBaseRate()>
                                                <cfelse>
                                                    <cfset nights = dateDiff('d', rc.Filter.getCheckInDate(), rc.Filter.getCheckOutDate())>
                                                    <cfset currency = rc.Hotel.getRooms()[1].getDailyRateCurrency()>
                                                    <cfset hotelTotal = rc.Hotel.getRooms()[1].getDailyRate()*nights>
                                                </cfif>
                                                #(currency EQ 'USD' ? DollarFormat(hotelTotal) : numberFormat(hotelTotal, '____.__')&' '&currency)#
                                                <cfset tripTotal = tripTotal + hotelTotal>
                                                <cfset tripCurrency = listAppend(tripCurrency, currency)>
    										</div>
    									</div>
    								</li>                               
                                </cfif>
                            </cfif>
                            <cfif segment EQ 'Car' AND rc.Filter.getCar() AND showCarTab>
                                <!---Car--->
                                <cfif rc.vehicleSelected>
    								<li>
    									<div class="row">
    										<div class="col-sm-12">
    											<a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Car')#"><i class="material-icons">directions_car</i></a><br>
    											#uCase(application.stCarVendors[rc.Vehicle.getVendorCode()])#<br>
    											<a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Car')#" class="cart-icon"><i class="material-icons" style="font-size:15px;">edit</i></a>
    											<a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Car&Remove=1')#" class="cart-icon"><i class="material-icons" style="font-size:15px;">delete</i></a>
    											#rc.Filter.getCarPickUpAirport()#<br>
    											#DateFormat(rc.Filter.getCarPickUpDateTime(), 'ddd, mmm d')# at #uCase(timeFormat(rc.Filter.getCarPickUpDateTime(), 'h:mm tt'))#<br>
    											<cfif rc.Filter.getCarDifferentLocations()>
    												#rc.Filter.getCarDropOffAirport()#<br>
    											</cfif>
    											#DateFormat(rc.Filter.getCarDropOffDateTime(), 'ddd, mmm d')# at #uCase(timeFormat(rc.Filter.getCarDropOffDateTime(), 'h:mm tt'))#<br>
                                                #(rc.Vehicle.getCurrency() EQ 'USD' ? DollarFormat(rc.Vehicle.getEstimatedTotalAmount()) : numberFormat(rc.Vehicle.getEstimatedTotalAmount(), '____.__')&' '&rc.Vehicle.getCurrency())#
                                                <cfset tripTotal = tripTotal + rc.Vehicle.getEstimatedTotalAmount()>
                                                <cfset tripCurrency = listAppend(tripCurrency, rc.Vehicle.getCurrency())>
    										</div>
    									</div>
    								</li>
                                </cfif>
                            </cfif>
                        </cfloop>
    					<cfif NOT rc.hotelSelected AND rc.Filter.getHotel() AND showHotelTab>
                            <!---Hotel--->
    						<li>
    							<div class="row">
    								<div class="col-sm-12">
    		                            <a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Hotel')#"><i class="material-icons">hotel</i></a>
    		                            <cfif rc.action CONTAINS 'hotel.'>In progress<cfelse>Up next</cfif>
    		                            <a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Hotel')#" class="cart-icon"><i class="material-icons" style="font-size:15px;">edit</i></a>
    		                            <a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Hotel&Remove=1')#" class="cart-icon"><i class="material-icons" style="font-size:15px;">delete</i></a>
    								</div>
    							</div>
    						</li>
                        </cfif>
                        <cfif NOT rc.vehicleSelected AND rc.Filter.getCar() AND showCarTab>
                            <!---Car--->
                            <li>
    							<div class="row">
    								<div class="col-sm-12">
    		                            <a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Car')#"><i class="material-icons">directions_car</i></a>
    		                            <cfif rc.action CONTAINS 'car.'>In progress<cfelse>Up next</cfif>
    		                            <a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Car')#" class="cart-icon"><i class="material-icons" style="font-size:15px;">edit</i></a>
    		                            <a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Car&Remove=1')#" class="cart-icon"><i class="material-icons" style="font-size:15px;">delete</i></a>
    								</div>
    							</div>
    						</li>
                        </cfif>
                        <cfif rc.filter.getPassthrough() NEQ 1 AND NOT (structKeyExists(cookie,"loginOrigin") AND cookie.loginOrigin EQ "STO") AND rc.Filter.getAir() EQ 1 AND NOT rc.airSelected>
                            <li>
    							<div class="row">
    								<div class="col-sm-12">
                               			<i class="material-icons">local_airport</i> <a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Air&Add=1')#">Add air</a>
    								</div>
    							</div>
    						</li>
                        </cfif>
                        <cfif NOT rc.hotelSelected AND rc.Filter.getHotel() EQ 0>
                            <li>
    							<div class="row">
    								<div class="col-sm-12">
                               			<i class="material-icons blue bold">hotel</i> <a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Hotel&Add=1')#">Add a hotel</a>
    								</div>
    							</div>
    						</li>
                        </cfif>
                        <cfif NOT rc.vehicleSelected AND rc.Filter.getCar() EQ 0>
                            <li>
    							<div class="row">
    								<div class="col-sm-12">
                                		<i class="material-icons blue bold">directions_car</i> <a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Car&Add=1')#">Add a car</a>
    								</div>
    							</div>
    						</li>
                        </cfif>                                            
                    </cfif>
                    <cfif rc.action DOES NOT CONTAIN 'air'
                        AND rc.action DOES NOT CONTAIN 'summary'>

                        <cfif len(trim(tripTotal))>
                            <div class="select-fare-button" style="padding-left:15px;">
                                <a href="?action=summary&SearchID=#rc.SearchID#" class="btn btn-primary">
                                    $#numberFormat(tripTotal, '____.__')#&nbsp;
                                    Check Out
                                </a>
                            </div>
                        </cfif>
                        
                    </cfif>
                </cfoutput>
            </ul>
        </nav>
    </cfif>
    <!-- /#sidebar-wrapper -->
</cfif>