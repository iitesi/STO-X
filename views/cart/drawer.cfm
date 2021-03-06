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
            <div class="z-depth-1">
                <div class="navbarheader">
                    <div class="navbarheader-open">
                        Itinerary for:
                    </div>
                    <div>
                        <button type="button" class="cart-close-icon" data-toggle="offcanvas">
                            <i class="material-icons">close</i>
                        </button>
                    </div>
                </div>
                <div class="navbarheader-close">
                    <cfoutput>#rc.Filter.getProfileUsername()#</cfoutput>
                </div>
            </div>
            
            <ul class="nav sidebar-nav container">
                <cfoutput>
                    <cfif displayCart>
                        <cfloop array="#itineraryOrder#" index="segment">
                            <cfif isNumeric(segment) AND showAirTab>
                                <!---Air--->
                                <cfif rc.airSelected>
                                    <cfloop collection="#rc.Air#" item="group" index="i">
                                        <cfif segment EQ i AND NOT structIsEmpty(group)>
                                            <li>
                                                <div class="col s12">
                                                    <div class="card horizontal">
                                                        <div class="card-image">
                                                            <i class="mdi mdi-airplane"></i>
                                                        </div>
                                                        <div class="card-stacked">
                                                            <div class="card-content">
                                                                <div class="item-details">
                                                                    <div class="item-carrier">
                                                                        <a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Air&Group=#i#')#"><img class="carrierimg" src="assets/img/airlines/#group.CarrierCode#_sm.png" title="#application.stAirVendors[group.CarrierCode].Name#"></a><br>
                                                                    </div>
                                                                    <div class="item-information">
                                                                        <div>#group.OriginAirportCode# - #group.DestinationAirportCode#</div>
                                                                        <div>#DateFormat(group.DepartureTime, 'DDD, MMM d, yyyy')#</div>
                                                                        <div>#TimeFormat(group.DepartureTime, 'h:mm tt')# - #TimeFormat(group.ArrivalTime, 'h:mm tt')#</div>
                                                                        <cfif structCount(rc.Air) EQ i+1
                                                                            AND structKeyExists(rc.Air[0], 'TotalPrice')>
                                                                            <cfif structKeyExists(Group, "Currency")>
                                                                                <cfset Currency = Group.Currency/>
                                                                            <cfelse>
                                                                                <cfset Currency = "USD"/>
                                                                            </cfif>
                                                                            <div class="total">
                                                                                #(Currency EQ 'USD' ? DollarFormat(rc.Air[0].TotalPrice) : numberFormat(rc.Air[0].TotalPrice, '____.__')&' '&Currency)#
                                                                            </div>
                                                                            <cfset tripTotal = tripTotal + rc.Air[0].TotalPrice>
                                                                            <cfset tripCurrency = listAppend(tripCurrency, 'USD')>
                                                                        </cfif>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div class="card-action">
                                                                <a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Air&Group=#i#')#">Edit Flight</a>
                                                            </div>
                                                        </div>
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
                                        <div class="col s12">
                                            <div class="card horizontal">
                                                <div class="card-image darken-1">
                                                    <i class="mdi mdi-hotel"></i>
                                                </div>
                                                <div class="card-stacked">
                                                    <div class="card-content">
                                                        <div class="item-information">
                                                            <div>#rc.Hotel.getPropertyName()#</div>
                                                            <div>#DateFormat(rc.filter.getCheckInDate(), 'DDD, MMM d')# to #DateFormat(rc.filter.getCheckOutDate(), 'DDD, MMM d')#</div>
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
                                                            <div class="total">
                                                                #(currency EQ 'USD' ? DollarFormat(hotelTotal) : numberFormat(hotelTotal, '____.__')&' '&currency)#
                                                            </div>
                                                            <cfset tripTotal = tripTotal + hotelTotal>
                                                            <cfset tripCurrency = listAppend(tripCurrency, currency)>
                                                        </div>
                                                    </div>
                                                    <div class="card-action">
                                                        <a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Hotel')#" class="cart-icon">Edit Hotel</a>
                                                        <a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Hotel&Remove=1')#" class="cart-icon">Remove Hotel</a>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
    								</li>                               
                                </cfif>
                            </cfif>
                            <cfif segment EQ 'Car' AND rc.Filter.getCar() AND showCarTab>
                                <!---Car--->
                                <cfif rc.vehicleSelected>
                                    <li>
                                        <div class="col s12">
                                            <div class="card horizontal">
                                                <div class="card-image darken-2">
                                                    <i class="mdi mdi-car"></i>
                                                </div>
                                                <div class="card-stacked">
                                                    <div class="card-content">
                                                        <div class="item-information">
                                                            <div>#uCase(application.stCarVendors[rc.Vehicle.getVendorCode()])#</div>
                                                            <div>#rc.Filter.getCarPickUpAirport()#</div>
                                                            <div>#DateFormat(rc.Filter.getCarPickUpDateTime(), 'ddd, mmm d')# at #uCase(timeFormat(rc.Filter.getCarPickUpDateTime(), 'h:mm tt'))#</div>
                                                            <cfif rc.Filter.getCarDifferentLocations()>
                                                                <div>#rc.Filter.getCarDropOffAirport()#</div>
                                                            </cfif>
                                                            <div>#DateFormat(rc.Filter.getCarDropOffDateTime(), 'ddd, mmm d')# at #uCase(timeFormat(rc.Filter.getCarDropOffDateTime(), 'h:mm tt'))#</div>
                                                            <div class="total">
                                                                #(rc.Vehicle.getCurrency() EQ 'USD' ? DollarFormat(rc.Vehicle.getEstimatedTotalAmount()) : numberFormat(rc.Vehicle.getEstimatedTotalAmount(), '____.__')&' '&rc.Vehicle.getCurrency())#
                                                            </div>
                                                            <cfset tripTotal = tripTotal + rc.Vehicle.getEstimatedTotalAmount()>
                                                            <cfset tripCurrency = listAppend(tripCurrency, rc.Vehicle.getCurrency())>
                                                        </div>
                                                    </div>
                                                    <div class="card-action">
                                                        <a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Car')#" class="cart-icon">Edit Car</a>
                                                        <a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Car&Remove=1')#" class="cart-icon">Remove Car</a>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
    								</li>
                                </cfif>
                            </cfif>
                        </cfloop>
                        <cfif NOT ArrayLen(itineraryOrder) AND showAirTab>
                            <!---Air--->
                            <li>
                                <div class="col s12">
                                    <div class="card horizontal">
                                        <div class="card-image">
                                            <i class="mdi mdi-airplane"></i>
                                        </div>
                                        <div class="card-stacked">
                                            <div class="card-content">
                                                <p>
                                                    Begin by selecting your flights
                                                </p>
                                            </div>
                                            <div class="card-action">
                                                <a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Air')#">Edit Flights</a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
    						</li>
                        </cfif>
    					<cfif NOT rc.hotelSelected AND rc.Filter.getHotel() AND showHotelTab>
                            <!---Hotel--->
                            <li>
                                <div class="col s12">
                                    <div class="card horizontal">
                                        <div class="card-image darken-1">
                                            <i class="mdi mdi-hotel"></i>
                                        </div>
                                        <div class="card-stacked">
                                            <div class="card-content">
                                                <p>
                                                    <cfif rc.action CONTAINS 'hotel.'>In progress<cfelse>Up next</cfif>
                                                </p>
                                            </div>
                                            <div class="card-action">
                                                <a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Hotel')#" class="cart-icon">Edit Hotel</a>
                                                <a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Hotel&Remove=1')#" class="cart-icon">Remove Hotel</a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
    						</li>
                        </cfif>
                        <cfif NOT rc.vehicleSelected AND rc.Filter.getCar() AND showCarTab>
                            <!---Car--->
                            <li>
                                <div class="col s12">
                                    <div class="card horizontal">
                                        <div class="card-image darken-2">
                                            <i class="mdi mdi-car"></i>
                                        </div>
                                        <div class="card-stacked">
                                            <div class="card-content">
                                                <p><cfif rc.action CONTAINS 'car.'>In progress<cfelse>Up next</cfif></p>
                                            </div>
                                            <div class="card-action">
                                                <a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Car')#" class="cart-icon">Edit Car</a>
    		                            <a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Car&Remove=1')#" class="cart-icon">Remove Car</a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
    						</li>
                        </cfif>
                        <cfif rc.filter.getPassthrough() NEQ 1 AND NOT (structKeyExists(cookie,"loginOrigin") AND cookie.loginOrigin EQ "STO") AND rc.Filter.getAir() EQ 1 AND NOT rc.airSelected>
                            <li>
    							<a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Air&Add=1')#" class="btn btn-default">Add air <i class="mdi mdi-airplane mdi-18px"></i></a>
    						</li>
                        </cfif>
                        <cfif NOT rc.hotelSelected AND rc.Filter.getHotel() EQ 0>
                            <li>
    							<a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Hotel&Add=1')#" class="btn btn-default">Add a hotel <i class="mdi mdi-hotel mdi-18px"></i></a>
    						</li>
                        </cfif>
                        <cfif NOT rc.vehicleSelected AND rc.Filter.getCar() EQ 0>
                            <li>
                                <a href="#buildURL('main?SearchID=#rc.SearchID#&Service=Car&Add=1')#" class="btn btn-default">Add a car <i class="mdi mdi-car mdi-18px"></i></a>
    						</li>
                        </cfif>                                            
                    </cfif>
                    <cfif rc.action DOES NOT CONTAIN 'air'
                        AND rc.action DOES NOT CONTAIN 'summary'>

                        <cfif len(trim(tripTotal))>
                            <li>
                                <div class="select-fare-button w100">
                                    <a href="?action=summary&SearchID=#rc.SearchID#" class="btn btn-primary btn-large w100">
                                        $#numberFormat(tripTotal, '____.__')#&nbsp;
                                        Check Out
                                    </a>
                                </div>
                            </li>
                        </cfif>
                        
                    </cfif>
                    <cfif rc.action CONTAINS 'summary'>
                        <cfif len(trim(tripTotal))>
                            <li>
                                <div class="col s12">
                                    <div class="card horizontal total-content">
                                        <div class="card-image darken-2">
                                            <i class="mdi mdi-currency-usd"></i>
                                        </div>
                                        <div class="card-stacked">
                                            <div class="card-content ">
                                                <div class="item-information">
                                                    Trip: $#numberFormat(tripTotal, '____.__')#
                                                 </div>
                                            </div>
                                          </div>
                                    </div>
                                </div>
                            </li>
                        </cfif>                        
                    </cfif>
                </cfoutput>
            </ul>
        </nav>
    </cfif>
    <!-- /#sidebar-wrapper -->
</cfif>