<cfinvoke component="views.search.widget" method="getAllAirlines" returnvariable="qAllAirlines" />
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=Edge" >
		<meta name="http-equiv" content="Content-type: text/html; charset=UTF-8;"/>
		<meta http-equiv="Pragma" content="no-cache">
		<meta http-equiv="Expires" content="-1">
		<meta http-equiv="cache-control" content="no-cache">
		<title>STO .:. The New Generation of Corporate Online Booking</title>

		<script src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script>
		<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.9.1/jquery-ui.min.js"></script>
		<script type="text/javascript" src="views/search/jquery.selectbox-0.5.js"></script>
		<script type="text/javascript" src="views/search/autosuggest.js"></script>
		<script type="text/javascript" src="views/search/custom-form-elements.js"></script>
		<link type="text/css" rel="stylesheet" href="views/search/stowidget.css" />
		<link type="text/css" rel="stylesheet" href="views/search/selectBox.css" />
		<link type="text/css" rel="stylesheet" href="http://code.jquery.com/ui/1.9.1/themes/base/jquery-ui.css" />

		<script type="text/javascript">

			function activatePlaceholders() {
				var detect = navigator.userAgent.toLowerCase();
				if (detect.indexOf("safari") > 0) return false;
				var inputs = document.getElementsByTagName("input");
    	       	for (var i=0;i<inputs.length;i++) {
					if (inputs[i].getAttribute("type") == "text") {
						if (inputs[i].getAttribute("placeholder") && inputs[i].getAttribute("placeholder").length > 0) {
							inputs[i].value = inputs[i].getAttribute("placeholder");
							inputs[i].style.color = "#CCCCCC";
							inputs[i].onclick = function() {
								if (this.value == this.getAttribute("placeholder")) {
									this.value = "";
									this.style.color = "#003366";
								}
								return false;
								}
							inputs[i].onblur = function() {
								if (this.value.length < 1) {
									this.value = this.getAttribute("placeholder");
								}
							}
						}
	        	   	}
				}
			}
			
			function setscreens() {
				document.getElementById("flight").style.display = "none";
				document.getElementById("hotel").style.display = "none";
				document.getElementById("car").style.display = "none";
				document.getElementById("flightcar").style.display = "none";
				document.getElementById("hotelcar").style.display = "none";
				document.getElementById("flighthotel").style.display = "none";
				document.getElementById("flighthotelcar").style.display = "none";
				if (document.getElementById("flight-checkbox").checked) {
					if (document.getElementById("hotel-checkbox").checked) {
						if (document.getElementById("car-checkbox").checked) {
							document.getElementById("flighthotelcar").style.display = "block";
						} else {
							document.getElementById("flighthotel").style.display = "block";
						}
					} else {
						if (document.getElementById("car-checkbox").checked) {
							document.getElementById("flightcar").style.display = "block";
						} else {
							document.getElementById("flight").style.display = "block";
						}
					}
				} else {
					if (document.getElementById("hotel-checkbox").checked) {
						if (document.getElementById("car-checkbox").checked) {
							document.getElementById("hotelcar").style.display = "block";
						} else {
							document.getElementById("hotel").style.display = "block";
						}
					} else {
						if (document.getElementById("car-checkbox").checked) {
							document.getElementById("car").style.display = "block";
						} else {
							document.getElementById("flight").style.display = "block";
							document.getElementById("flight-checkbox").checked = true;
							document.getElementById("flight-checkbox_ckb").style.backgroundPosition = "0 -" + checkboxHeight*3 + "px";;
						}
					}
				}
			}
			
			window.onload = function() {
				activatePlaceholders();
				Custom.init();
				
				$("#flight_for").select(function(){
					if ( $('#flight_for').val() == "guest" ) {
						document.getElementById("flight-department").style.display = "block";
					} else {
						document.getElementById("flight-department").style.display = "none";
					}
				});
				
				$('#hotelvenue').click(function(){
					document.getElementById("hotel_location").value = "select an office or venue";
					document.getElementById("hotel_location").style.color = "#CCCCCC";
					document.getElementById("hotelvenue").className = "small-button segmented-last selected";
					document.getElementById("hotelairport").className = "small-button segmented-first";
				});

				$("#hotelairport").click(function(){
					document.getElementById("hotel_location").value = "address, landmark, or airport";
					document.getElementById("hotel_location").style.color = "#CCCCCC";
					document.getElementById("hotelvenue").className = "small-button segmented-last";
					document.getElementById("hotelairport").className = "small-button segmented-first selected";
				});

				$("#hotel_for").select(function(){
					if ( $('#hotel_for').val() == "guest" ) {
						document.getElementById("hotel-department").style.display = "block";
					} else {
						document.getElementById("hotel-department").style.display = "none";
					}
				});

				$('#dropoffcity').click(function(){
					document.getElementById("car_droploc").value = "drop-off city";
					document.getElementById("car_droploc").style.color = "#CCCCCC";
					document.getElementById("dropoffcity").className = "small-button segmented-last selected";
					document.getElementById("dropoffairport").className = "small-button segmented-first";
				});

				$("#dropoffairport").click(function(){
					document.getElementById("car_droploc").value = "drop-off airport";
					document.getElementById("car_pickuploc").placeholder = "pick-up airport";
					document.getElementById("car_droploc").style.color = "#CCCCCC";
					document.getElementById("dropoffcity").className = "small-button segmented-last";
					document.getElementById("dropoffairport").className = "small-button segmented-first selected";
				});

				$('#pickupcity').click(function(){
					document.getElementById("car_pickuploc").placeholder = "city";
					document.getElementById("car_pickuploc").style.color = "#CCCCCC";
					document.getElementById("pickupcity").className = "small-button segmented-last selected";
					document.getElementById("pickupairport").className = "small-button segmented-first";
				});

				$("#pickupairport").click(function(){
					document.getElementById("car_pickuploc").placeholder = "airport";
					document.getElementById("car_pickuploc").style.color = "#CCCCCC";
					document.getElementById("pickupcity").className = "small-button segmented-last";
					document.getElementById("pickupairport").className = "small-button segmented-first selected";
				});

				$("#dropoffdifferent").click(function(){
					document.getElementById("car_pickuploc").placeholder = "pick-up airport";
					document.getElementById("car_pickuploc").style.color = "#CCCCCC";
					document.getElementById("differentdrop").style.display = "block";
					document.getElementById("dropoffdifferent").className = "small-button segmented-last selected";
					document.getElementById("dropoffsame").className = "small-button segmented-first";
				});

				$("#dropoffsame").click(function(){
					document.getElementById("car_pickuploc").placeholder = "airport";
					document.getElementById("car_pickuploc").style.color = "#CCCCCC";
					document.getElementById("differentdrop").style.display = "none";
					document.getElementById("dropoffdifferent").className = "small-button segmented-last";
					document.getElementById("dropoffsame").className = "small-button segmented-first selected";
				});

				$("#car_for").select(function(){
					if ( $('#car_for').val() == "guest" ) {
						document.getElementById("car-department").style.display = "block";
					} else {
						document.getElementById("car-department").style.display = "none";
					}
				});

				$("#flight-checkbox_ckb").click(function(){
					setscreens();
				});

				$("#hotel-checkbox_ckb").click(function(){
					setscreens();
				});

				$("#car-checkbox_ckb").click(function(){
					setscreens();
				});

				$("#hotelcar_for").select(function(){
					if ( $('#hotelcar_for').val() == "guest" ) {
						document.getElementById("hotelcar-department").style.display = "block";
					} else {
						document.getElementById("hotelcar-department").style.display = "none";
					}
				});
				
				$('#hotelcarvenue').click(function(){
					document.getElementById("hotelcar_hotellocation").value = "select an office or venue";
					document.getElementById("hotelcar_hotellocation").style.color = "#CCCCCC";
					document.getElementById("hotelcarvenue").className = "small-button segmented-last selected";
					document.getElementById("hotelcarairport").className = "small-button segmented-first";
				});

				$("#hotelcarairport").click(function(){
					document.getElementById("hotelcar_hotellocation").value = "address, landmark, or airport";
					document.getElementById("hotelcar_hotellocation").style.color = "#CCCCCC";
					document.getElementById("hotelcarvenue").className = "small-button segmented-last";
					document.getElementById("hotelcarairport").className = "small-button segmented-first selected";
				});

				$('#hotelcar-dropcity').click(function(){
					document.getElementById("hotelcar_cardrop").value = "drop-off city";
					document.getElementById("hotelcar_cardrop").style.color = "#CCCCCC";
					document.getElementById("hotelcar-dropcity").className = "small-button segmented-last selected";
					document.getElementById("hotelcar-dropairport").className = "small-button segmented-first";
				});

				$("#hotelcar-dropairport").click(function(){
					document.getElementById("hotelcar_cardrop").value = "drop-off airport";
					document.getElementById("hotelcar_carpickup").value = "pick-up airport";
					document.getElementById("hotelcar_cardrop").style.color = "#CCCCCC";
					document.getElementById("hotelcar-dropcity").className = "small-button segmented-last";
					document.getElementById("hotelcar-dropairport").className = "small-button segmented-first selected";
				});

				$('#hotelcar-pickupcity').click(function(){
					document.getElementById("hotelcar_carpickup").value = "city";
					document.getElementById("hotelcar_carpickup").style.color = "#CCCCCC";
					document.getElementById("hotelcar-pickupcity").className = "small-button segmented-last selected";
					document.getElementById("hotelcar-pickupairport").className = "small-button segmented-first";
				});

				$("#hotelcar-pickupairport").click(function(){
					document.getElementById("hotelcar_carpickup").value = "airport";
					document.getElementById("hotelcar_carpickup").style.color = "#CCCCCC";
					document.getElementById("hotelcar-pickupcity").className = "small-button segmented-last";
					document.getElementById("hotelcar-pickupairport").className = "small-button segmented-first selected";
				});

				$("#hotelcar-dropoffdifferent").click(function(){
					document.getElementById("hotelcar_carpickup").value = "pick-up airport";
					document.getElementById("hotelcar_carpickup").style.color = "#CCCCCC";
					document.getElementById("hotelcar-differentdrop").style.display = "block";
					document.getElementById("hotelcar-dropoffdifferent").className = "small-button segmented-last selected";
					document.getElementById("hotelcar-dropoffsame").className = "small-button segmented-first";
				});

				$("#hotelcar-dropoffsame").click(function(){
					document.getElementById("hotelcar_carpickup").value = "airport";
					document.getElementById("hotelcar_carpickup").style.color = "#CCCCCC";
					document.getElementById("hotelcar-differentdrop").style.display = "none";
					document.getElementById("hotelcar-dropoffdifferent").className = "small-button segmented-last";
					document.getElementById("hotelcar-dropoffsame").className = "small-button segmented-first selected";
				});

				$("#flightcar_for").select(function(){
					if ( $('#flightcar_for').val() == "guest" ) {
						document.getElementById("flightcar-department").style.display = "block";
					} else {
						document.getElementById("flightcar-department").style.display = "none";
					}
				});
				
				$("#flighthotel_for").select(function(){
					if ( $('#flighthotel_for').val() == "guest" ) {
						document.getElementById("flighthotel-department").style.display = "block";
					} else {
						document.getElementById("flighthotel-department").style.display = "none";
					}
				});
			}
			
			$(document).ready(function() {
    			$('#flight_for').selectbox();
			    $('#flight_dept').selectbox();
			    $('#flight_departaol').selectbox();
		    	$('#flight_departtime').selectbox();
			    $('#flight_returnaol').selectbox();
			    $('#flight_returntime').selectbox();
			    $('#flight_airline').selectbox();
		    	$('#flight_cabin').selectbox();
			    $('#hotel_for').selectbox();
	    		$('#hotel_dept').selectbox();
				$('#hotel_radius').selectbox();
				$('#hotel_rooms').selectbox();
				$('#car_for').selectbox();
				$('#car_dept').selectbox();
				$('#car_pickuptime').selectbox();
				$('#car_droptime').selectbox();
				$('#cars').selectbox();
				$('#hotelcar_for').selectbox();
				$('#hotelcar_dept').selectbox();
				$('#hotelcar_radius').selectbox();
				$('#hotelcar_intime').selectbox();
				$('#hotelcar_outtime').selectbox();
			    $( "#flight_fromlocation" ).autocomplete({ source: airports, minLength: 3 });
			    $( "#flight_tolocation" ).autocomplete({ source: airports, minLength: 3 });
			    $( "#flightcar_fromlocation" ).autocomplete({ source: airports, minLength: 3 });
			    $( "#flightcar_tolocation" ).autocomplete({ source: airports, minLength: 3 });
			    $( "#flightcar_pickuploc" ).autocomplete({ source: airports, minLength: 3 });
			    $( "#flighthotel_fromlocation" ).autocomplete({ source: airports, minLength: 3 });
			    $( "#flighthotel_tolocation" ).autocomplete({ source: airports, minLength: 3 });
			    $( "#flighthotelcar_tolocation" ).autocomplete({ source: airports, minLength: 3 });
			    $( "#flighthotelcar_fromlocation" ).autocomplete({ source: airports, minLength: 3 });
			    $( "#flighthotelcar_pickuploc" ).autocomplete({ source: airports, minLength: 3 });
			    $( "#hotelcar_carpickup" ).autocomplete({ source: airports, minLength: 3 });
			    $( "#hotelcar_cardrop" ).autocomplete({ source: airports, minLength: 3 });
			    $( "#car_pickuploc" ).autocomplete({ source: airports, minLength: 3 });
			    $( "#car_droploc" ).autocomplete({ source: airports, minLength: 3 });
    			$('#flightcar_for').selectbox();
			    $('#flightcar_dept').selectbox();
			    $('#flightcar_departaol').selectbox();
		    	$('#flightcar_departtime').selectbox();
			    $('#flightcar_returnaol').selectbox();
			    $('#flightcar_returntime').selectbox();
			    $('#flightcar_airline').selectbox();
		    	$('#flightcar_cabin').selectbox();
				$('#flightcar_cars').selectbox();
    			$('#flighthotel_for').selectbox();
			    $('#flighthotel_dept').selectbox();
			    $('#flighthotel_departaol').selectbox();
		    	$('#flighthotel_departtime').selectbox();
			    $('#flighthotel_returnaol').selectbox();
			    $('#flighthotel_returntime').selectbox();
				$('#flighthotel_radius').selectbox();
			    $('#flighthotel_airline').selectbox();
		    	$('#flighthotel_cabin').selectbox();
				$('#flighthotel_rooms').selectbox();
    			$('#flighthotelcar_for').selectbox();
			    $('#flighthotelcar_dept').selectbox();
			    $('#flighthotelcar_departaol').selectbox();
		    	$('#flighthotelcar_departtime').selectbox();
			    $('#flighthotelcar_returnaol').selectbox();
			    $('#flighthotelcar_returntime').selectbox();
				$('#flighthotelcar_radius').selectbox();
			    $('#flighthotelcar_airline').selectbox();
		    	$('#flighthotelcar_cabin').selectbox();
				$('#flighthotelcar_rooms').selectbox();
				$('#flighthotelcar_cars').selectbox();
				$('#hotelcar_cars').selectbox();
				$('#hotelcar_rooms').selectbox();
			});

		</script>
	</head>
	<body id="body" class="">
		
        <div id="front-search" class="frontbox">
          <div class="selection-row">
             <div class="input-container">
 				<input id="flight-checkbox" type="checkbox" name="flight-checkbox" class="styled" value="true" checked />&nbsp;Flights
			 </div>
             <div class="input-container">
				<input id="hotel-checkbox" type="checkbox" name="hotel-checkbox" class="styled" value="true" />&nbsp;Hotels
			 </div>
             <div class="input-container">
				<input id="car-checkbox" type="checkbox" name="car-checkbox" class="styled" value="true" />&nbsp;Cars
			 </div>
			 <div class="clear"></div>
		  </div>	
		  <div id="flight" class="search-form-wrapper" style="display: block;">
			<cfoutput>
			<form action="#buildURL('search.addSearchRecord')#&Search_ID=206352" method="post" class="search-form form-flight" id="flight" name="flight">
				<input type="hidden" name="Searchtype" value="flightonly">
				<input type="hidden" name="User_ID" id="User_ID" value="175401">
			</cfoutput>
				<div class="form-padding">
                <div class="search-logo image-flight"></div>

                <div class="error-status"></div>

                <div class="full-row">
                  <label for="flight_for" class="biglabel">for</label>

                  <div class="input-row">
                    <div class="input-container">
						<select name="for" id="flight_for">
							<option value="Myself">myself</option>
							<option value="guest">guest</option>
							<option value="Test1">test1</option>
							<option value="Test2">test2</option>
						</select>
                    </div>

                    <div class="error-row error error-for"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div id="flight-department" class="full-row" style="display:none">
                  <label for="flight_dept" class="biglabel">dept.</label>

                  <div class="input-row">
                    <div class="input-container">
						<select name="dept" id="flight_dept">
							<option value="D1">Department 1</option>
							<option value="D2">Department 2</option>
							<option value="D3">Department 3</option>
							<option value="D4">Department 4</option>
						</select>
                    </div>

                    <div class="error-row error error-for"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div class="full-row">
                  <label for="flight_fromlocation" class="biglabel">from</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input id="flight_fromlocation" name="flight_fromlocation" placeholder="place or airport" type="text" class="field-from0" />
                    </div>

                    <div class="error-row error error-from0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div class="full-row">
                  <label for="flight_tolocation" class="biglabel">to</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input id="flight_tolocation" name="flight_tolocation" placeholder="place or airport" type="text" class="field-to0" />
                    </div>

                    <div class="error-row error error-to0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div class="full-row highlight-date0">
                  <label for="flight_departdate" class="biglabel">depart</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input name="flight_departdate" placeholder="date" type="text" id=
                      "flight_departdate" class=
                      "flex field-date0 date tag-date0" />
                    </div>
                    <div class="input-container">
						<select name="flight_departaol" id="flight_departaol" >
							<option value="A" selected>Arrive</option>
							<option value="D">Leave</option>
						</select>
                    </div>
                    <div class="input-container">
						<select name="flight_departtime" id="flight_departtime" >
							<option value="">Anytime</option>
							<option value="06:00">Early Morning</option>
							<option value="10:00">Late Morning</option>
							<option value="14:00">Afternoon</option>
							<option value="18:00">Evening</option>
							<option value="00:00">Red-eye</option>
							<cfloop from="0" to="23" index="time">
								<cfoutput>
									<option value="#variables.time#:00"<cfif variables.time EQ 8> selected="selected"</cfif>>#TimeFormat(CreateTime(variables.time, 00, 00), 'h:mm tt')#</option>
								</cfoutput>
							</cfloop>
						</select>
                   </div>

                    <div class="error-row error error-date0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div class="full-row highlight-date1">
                  <label for="flight_returndate" class="biglabel">return</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input name="flight_returndate" placeholder="optional for one-way" type="text" id="flight_returndate" class=
                      "flex field-date1 date tag-date1" />
                    </div>
                    <div class="input-container">
						<select name="flight_returnaol" id="flight_returnaol" >
							<option value="A">Arrive</option>
							<option value="D" selected>Leave</option>
						</select>
                    </div>
                    <div class="input-container">
						<select name="flight_returntime" id="flight_returntime" >
							<option value="">Anytime</option>
							<option value="06:00">Early Morning</option>
							<option value="10:00">Late Morning</option>
							<option value="14:00">Afternoon</option>
							<option value="18:00">Evening</option>
							<option value="00:00">Red-eye</option>
							<cfloop from="0" to="23" index="time">
								<cfoutput>
									<option value="#variables.time#:00"<cfif variables.time EQ 8> selected="selected"</cfif>>#TimeFormat(CreateTime(variables.time, 00, 00), 'h:mm tt')#</option>
								</cfoutput>
							</cfloop>
						</select>
                   </div>

                    <div class="error-row error error-date1"></div>
                  </div>

                  <div class="clear"></div>
                </div>

				<div class="options">

				  <select class="field-flight-airline" tabindex="" name="flight_airline" id="flight_airline">
					<option selected="selected" value="">All Airlines</option>
						<cfloop query="qAllAirlines">
							<cfoutput><option value="#Vendor_Code#" >#Vendor_Name#</option></cfoutput>
						</cfloop>
				  </select>
						 
				  <select class="field-flight-cabin" tabindex="" name="flight_cabin" id="flight_cabin">
					<option selected="selected" value="Y">Economy</option>
					<option value="C">Business</option>
					<option value="F">First</option>
				  </select>
				</div>
				<div class="submit-row">
				  <button class="status submit darkbookingbutton" type="submit"> Search! </button>
				</div>
			  </div>
			</form>
		  </div>
		  <div id="hotel" class="search-form-wrapper" style="display: none;">
			<cfoutput>
			<form action="#buildURL('search.addSearchRecord')#&Search_ID=206352" method="post" class="search-form form-flight" id="flight" name="flight">
				<input type="hidden" name="Searchtype" value="hotelonly">
				<input type="hidden" name="User_ID" id="User_ID" value="175401">
			</cfoutput>
				<div class="form-padding">
                <div class="search-logo image-flight"></div>

                <div class="error-status"></div>
	
                <div class="full-row">
                  <label for="hotel_for" class="biglabel">for</label>

                  <div class="input-row">
                    <div class="input-container">
						<select name="for" id="hotel_for">
							<option value="Myself">myself</option>
							<option value="guest">guest</option>
							<option value="Test1">test1</option>
							<option value="Test2">test2</option>
						</select>
                    </div>

                    <div class="error-row error error-for"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div id="hotel-department" class="full-row" style="display:none">
                  <label for="hotel_dept" class="biglabel">dept.</label>

                  <div class="input-row">
                    <div class="input-container">
						<select name="dept" id="hotel_dept">
							<option value="D1">Department 1</option>
							<option value="D2">Department 2</option>
							<option value="D3">Department 3</option>
							<option value="D4">Department 4</option>
						</select>
                    </div>

                    <div class="error-row error error-for"></div>
                  </div>

                  <div class="clear"></div>
                </div>

				<div class="hoteloptions">
				  <select class="hotel_radius" tabindex="" name="hotel_radius" id="hotel_radius">
					<option value="1">in 1 mile of</option>
					<option value="2">in 2 miles of</option>
					<option selected="selected" value="5">in 5 miles of</option>
					<option value="10">in 10 miles of</option>
					<option value="15">in 15 miles of</option>
					<option value="20">in 20 miles of</option>
					<option value="25">in 25 miles of</option>
				  </select>
				  <div class="area-buttons">
					<div id="hotelairport" class="small-button segmented-first selected">Address/Airport</div>
					<div id="hotelvenue" class="small-button segmented-last">Office/Venues</div>
				  </div>
				</div>

                <div class="full-row">
                  <label for="hotel_location" class="biglabel">where</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input id="hotel_location" name="hotel_location" placeholder="address, landmark, or airport" type="text" class=
                      " field-from0 autocomplete routelang ac_id-achot1" />
                    </div>

                    <div class="error-row error error-from0"></div>
                  </div>

                  <div class="clear"></div>
                </div>
                <div class="full-row highlight-date0">
                  <label for="hotel_indate" class="biglabel">in</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input name="hotel_indate" placeholder="date" type="text" id=
                      "hotel_indate" class=
                      "flex field-date0 date tag-date0" />
                    </div>

                    <div class="error-row error error-date0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div class="full-row highlight-date1">
                  <label for="hotel_outdate" class="biglabel">out</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input name="hotel_outdate" placeholder="date" type="text" id="hotel_outdate" class=
                      "flex field-date1 date tag-date1" />
                    </div>

                    <div class="error-row error error-date1"></div>
                  </div>

                  <div class="clear"></div>
                </div>

				<div class="options">
						 
				  <select class="field-flight-cabin" tabindex="" name="hotel_rooms" id="hotel_rooms">
					<option selected="selected" value="1">1 Room</option>
					<option value="2">2 Rooms</option>
					<option value="3">3 Rooms</option>
				  </select>
				</div>
				<div class="submit-row">
				  <button class="status submit darkbookingbutton" type="submit"> Search! </button>
				</div>
			  </div>
			</form>
		  </div>
		  <div id="car" class="search-form-wrapper" style="display: none;">
			<cfoutput>
			<form action="#buildURL('search.addSearchRecord')#&Search_ID=206352" method="post" class="search-form form-flight" id="car" name="car">
				<input type="hidden" name="Searchtype" value="caronly">
				<input type="hidden" name="User_ID" id="User_ID" value="175401">
			</cfoutput>
				<div class="form-padding">
                <div class="search-logo image-flight"></div>

                <div class="error-status"></div>

                <div class="full-row">
                  <label for="car_for" class="biglabel">for</label>

                  <div class="input-row">
                    <div class="input-container">
						<select name="for" id="car_for">
							<option value="175401">myself</option>
							<option value="guest">guest</option>
							<option value="Test1">test1</option>
							<option value="Test2">test2</option>
						</select>
                    </div>

                    <div class="error-row error error-for"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div id="car-department" class="full-row" style="display:none">
                  <label for="car_dept" class="biglabel">dept.</label>

                  <div class="input-row">
                    <div class="input-container">
						<select name="dept" id="car_dept">
							<option value="D1">Department 1</option>
							<option value="D2">Department 2</option>
							<option value="D3">Department 3</option>
							<option value="D4">Department 4</option>
						</select>
                    </div>

                    <div class="error-row error error-for"></div>
                  </div>

                  <div class="clear"></div>
                </div>

				<div class="caroptions">
				  <div id="pickupairport" class="small-button segmented-first selected">At Airport</div>
				  <div id="pickupcity" class="small-button segmented-last">In City</div>
				  <div class="drop-buttons">
					<div id="dropoffsame" class="small-button segmented-first selected">Same Drop-off</div>
					<div id="dropoffdifferent" class="small-button segmented-last">Different Drop-off</div>
				  </div>
				</div>

                <div class="full-row">
                  <label for="car_pickuploc" class="biglabel">where</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input id="car_pickuploc" name="car_pickuploc" placeholder="airport" type="text" class=
                      "field-from0 autocomplete routelang ac_id-accar1" />
                    </div>

                    <div class="error-row error error-from0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

				<div id="differentdrop" style="display:none" >
				  <div class="caroptions">
					<div id="dropoffairport" class="small-button segmented-first selected">At Airport</div>
					<div id="dropoffcity" class="small-button segmented-last">In City</div>
				  </div>

				  <div class="full-row">
					<label for="car_droploc" class="biglabel">&nbsp;</label>

					<div class="input-row">
                      <div class="input-container">
						<input id="car_droploc" name="car_droploc" placeholder="drop-off airport" type="text" class=
						  " field-drop0 autocomplete routelang ac_id-accar2" />
                      </div>

                      <div class="drop-row">
						<ul id="accar2" class="ac-drop">
                          <li class="ac-row stub">trst</li>

                          <li class="ac-table stub">
							<table cellspacing="0"></table>
                          </li>
						</ul>
                      </div>

                      <div class="error-row error error-from0"></div>
					</div>

					<div class="clear"></div>
				  </div>
				</div>
				<div class="full-row highlight-date0">
                  <label for="car_pickupdate" class="biglabel">pick-up</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input name="car_pickupdate" placeholder="date" type="text" id=
                      "car_pickupdate" class=
                      "flex field-date0 date tag-date0" />
                    </div>
					
                    <div class="input-container">
						<select name="car_pickuptime" id="car_pickuptime" >
							<cfloop from="0" to="23" index="time">
								<cfoutput>
									<option value="#variables.time#:00"<cfif variables.time EQ 8> selected="selected"</cfif>>#TimeFormat(CreateTime(variables.time, 00, 00), 'h:mm tt')#</option>
								</cfoutput>
							</cfloop>
						</select>
                   </div>

                    <div class="error-row error error-date0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div class="full-row highlight-date1">
                  <label for="car_dropdate" class="biglabel">drop-off</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input name="car_dropdate" placeholder="date" type="text" id="car_dropdate" class=
                      "flex field-date1 date tag-date1" />
                    </div>
					
                    <div class="input-container">
						<select name="car_droptime" id="car_droptime" >
							<cfloop from="0" to="23" index="time">
								<cfoutput>
									<option value="#variables.time#:00"<cfif variables.time EQ 8> selected="selected"</cfif>>#TimeFormat(CreateTime(variables.time, 00, 00), 'h:mm tt')#</option>
								</cfoutput>
							</cfloop>
						</select>
                   </div>

                    <div class="error-row error error-date1"></div>
                  </div>

                  <div class="clear"></div>
                </div>

				<div class="options">
						 
				  <select class="field-cars" tabindex="" name="cars" id="cars">
					<option selected="selected" value="1">1 Car</option>
					<option value="2">2 Cars</option>
					<option value="3">3 Cars</option>
					<option value="4">4 Cars</option>
				  </select>
			</div>
				<div class="submit-row">
				  <button class="status submit darkbookingbutton" type="submit"> Search! </button>
				</div>
			  </div>
			</form>
		  </div>
		  <div id="hotelcar" class="search-form-wrapper" style="display: none;">
			<cfoutput>
			<form action="#buildURL('search.addSearchRecord')#&Search_ID=206352" method="post" class="search-form form-flight" id="flight" name="flight">
				<input type="hidden" name="Searchtype" value="hotelcar">
				<input type="hidden" name="User_ID" id="User_ID" value="175401">
			</cfoutput>
				<div class="form-padding">
                <div class="search-logo image-flight"></div>

                <div class="error-status"></div>
				<input type="hidden" name="form" value="flight" />

                <div class="full-row">
                  <label for="hotelcar_for" class="biglabel">for</label>

                  <div class="input-row">
                    <div class="input-container">
						<select name="for" id="hotelcar_for">
							<option value="Myself">myself</option>
							<option value="guest">guest</option>
							<option value="Test1">test1</option>
							<option value="Test2">test2</option>
						</select>
                    </div>

                    <div class="error-row error error-for"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div id="hotelcar-department" class="full-row" style="display:none">
                  <label for="hotelcar_dept" class="biglabel">dept.</label>

                  <div class="input-row">
                    <div class="input-container">
						<select name="dept" id="hotelcar_dept">
							<option value="D1">Department 1</option>
							<option value="D2">Department 2</option>
							<option value="D3">Department 3</option>
							<option value="D4">Department 4</option>
						</select>
                    </div>

                    <div class="error-row error error-for"></div>
                  </div>

                  <div class="clear"></div>
                </div>

				<div class="hoteloptions">
				  <select class="hotel_radius" tabindex="" name="hotelcar_radius" id="hotelcar_radius">
					<option value="1">in 1 mile of</option>
					<option value="2">in 2 miles of</option>
					<option selected="selected" value="5">in 5 miles of</option>
					<option value="10">in 10 miles of</option>
					<option value="15">in 15 miles of</option>
					<option value="20">in 20 miles of</option>
					<option value="25">in 25 miles of</option>
				  </select>
				  <div class="area-buttons">
					<div id="hotelcarairport" class="small-button segmented-first selected">Address/Airport</div>
					<div id="hotelcarvenue" class="small-button segmented-last">Office/Venues</div>
				  </div>
				</div>

                <div class="full-row">
                  <label for="hotelcar_hotellocation" class="biglabel">hotel</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input id="hotelcar_hotellocation" name="hotelcar_hotellocation" placeholder="address, landmark, or airport" type="text" class=
                      " field-from0 autocomplete routelang ac_id-achot1" />
                    </div>

                    <div class="error-row error error-from0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

				<div class="caroptions">
				  <div id="hotelcar-pickupairport" class="small-button segmented-first selected">At Airport</div>
				  <div id="hotelcar-pickupcity" class="small-button segmented-last">In City</div>
				  <div class="drop-buttons">
					<div id="hotelcar-dropoffsame" class="small-button segmented-first selected">Same Drop-off</div>
					<div id="hotelcar-dropoffdifferent" class="small-button segmented-last">Different Drop-off</div>
				  </div>
				</div>

                <div class="full-row">
                  <label for="hotelcar_carpickup" class="biglabel">car</label>
                  <div class="input-row">
                    <div class="input-container">
                      <input id="hotelcar_carpickup" name="hotelcar_carpickup" placeholder="airport" type="text" class=
                      " field-from0 autocomplete routelang ac_id-accar1" />
                    </div>

                    <div class="error-row error error-from0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

				<div id="hotelcar-differentdrop" style="display:none" >
				  <div class="caroptions">
					<div id="hotelcar-dropairport" class="small-button segmented-first selected">At Airport</div>
					<div id="hotelcar-dropcity" class="small-button segmented-last">In City</div>
				  </div>

				  <div class="full-row">
                  <label for="hotelcar_cardrop" class="biglabel">&nbsp;</label>
					<div class="input-row">
                      <div class="input-container">
						<input id="hotelcar_cardrop" name="hotelcar_cardrop" placeholder="drop-off airport" type="text" class=
						  " field-drop0 autocomplete routelang ac_id-accar2" />
                      </div>

                      <div class="error-row error error-from0"></div>
					</div>

					<div class="clear"></div>
				  </div>
				</div>
				<div class="full-row highlight-date0">
                  <label for="hotelcar_indate" class="biglabel">in</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input name="hotelcar_indate" placeholder="date" type="text" id=
                      "hotelcar_indate" class=
                      "flex field-date0 date tag-date0" />
                    </div>
					
                    <div class="input-container">
						<div class="bigtext">&nbsp;&nbsp;pickup</div>
					</div>
					
                    <div class="input-container">
						<select name="hotelcar_intime" id="hotelcar_intime" >
							<cfloop from="0" to="23" index="time">
								<cfoutput>
									<option value="#variables.time#:00"<cfif variables.time EQ 8> selected="selected"</cfif>>#TimeFormat(CreateTime(variables.time, 00, 00), 'h:mm tt')#</option>
								</cfoutput>
							</cfloop>
						</select>
                   </div>

                    <div class="error-row error error-date0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div class="full-row highlight-date1">
                  <label for="hotelcar_outdate" class="biglabel">out</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input name="hotelcar_outdate" placeholder="date" type="text" id="hotelcar_outdate" class=
                      "flex field-date1 date tag-date1" />
                    </div>
					
                    <div class="input-container">
						<div class="bigtext">drop-off</div>
					</div>
					
                    <div class="input-container">
						<select name="hotelcar_outtime" id="hotelcar_outtime" >
							<cfloop from="0" to="23" index="time">
								<cfoutput>
									<option value="#variables.time#:00"<cfif variables.time EQ 8> selected="selected"</cfif>>#TimeFormat(CreateTime(variables.time, 00, 00), 'h:mm tt')#</option>
								</cfoutput>
							</cfloop>
						</select>
                   </div>

                    <div class="error-row error error-date1"></div>
                  </div>

                  <div class="clear"></div>
                </div>

				<div class="options">
						 
				  <select class="field-flight-cabin" tabindex="" name="hotelcar_rooms" id="hotelcar_rooms">
					<option selected="selected" value="1">1 Room</option>
					<option value="2">2 Rooms</option>
					<option value="3">3 Rooms</option>
				  </select>
						 
				  <select class="field-cars" tabindex="" name="hotelcar_cars" id="hotelcar_cars">
					<option selected="selected" value="1">1 Car</option>
					<option value="2">2 Cars</option>
					<option value="3">3 Cars</option>
					<option value="4">4 Cars</option>
				  </select>

				  </div>
				<div class="submit-row">
				  <button class="status submit darkbookingbutton" type="submit"> Search! </button>
				</div>
			  </div>
			</form>
		  </div>
		  <div id="flightcar" class="search-form-wrapper" style="display: none;">
			<cfoutput>
			<form action="#buildURL('search.addSearchRecord')#&Search_ID=206352" method="post" class="search-form form-flight" id="flight" name="flight">
				<input type="hidden" name="Searchtype" value="Flightcar">
				<input type="hidden" name="User_ID" id="User_ID" value="175401">
			</cfoutput>
				<div class="form-padding">
                <div class="search-logo image-flight"></div>

                <div class="error-status"></div>
				<input type="hidden" name="form" value="flight" />

                <div class="full-row">
                  <label for="flightcar_for" class="biglabel">for</label>

                  <div class="input-row">
                    <div class="input-container">
						<select name="for" id="flightcar_for">
							<option value="Myself">myself</option>
							<option value="guest">guest</option>
							<option value="Test1">test1</option>
							<option value="Test2">test2</option>
						</select>
                    </div>

                    <div class="error-row error error-for"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div id="flightcar-department" class="full-row" style="display:none">
                  <label for="flightcar_dept" class="biglabel">dept.</label>

                  <div class="input-row">
                    <div class="input-container">
						<select name="dept" id="flightcar_dept">
							<option value="D1">Department 1</option>
							<option value="D2">Department 2</option>
							<option value="D3">Department 3</option>
							<option value="D4">Department 4</option>
						</select>
                    </div>

                    <div class="error-row error error-for"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div class="full-row">
                  <label for="flightcar_fromlocation" class="biglabel">from</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input id="flightcar_fromlocation" name="flightcar_fromlocation" placeholder="place or airport" type="text" class="field-from0" />
                    </div>

                    <div class="error-row error error-from0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div class="full-row">
                  <label for="flightcar_tolocation" class="biglabel">to</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input id="flightcar_tolocation" name="flightcar_tolocation" placeholder="place or airport" type="text" class="field-to0" />
                    </div>

                    <div class="error-row error error-to0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div class="full-row highlight-date0">
                  <label for="flightcar_departdate" class="biglabel">depart</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input name="flightcar_departdate" placeholder="date" type="text" id=
                      "flightcar_departdate" class=
                      "flex field-date0 date tag-date0" />
                    </div>
                    <div class="input-container">
						<select name="flightcar_departaol" id="flightcar_departaol" >
							<option value="A" selected>Arrive</option>
							<option value="D">Leave</option>
						</select>
                    </div>
                    <div class="input-container">
						<select name="flightcar_departtime" id="flightcar_departtime" >
							<option value="">Anytime</option>
							<option value="06:00">Early Morning</option>
							<option value="10:00">Late Morning</option>
							<option value="14:00">Afternoon</option>
							<option value="18:00">Evening</option>
							<option value="00:00">Red-eye</option>
							<cfloop from="0" to="23" index="time">
								<cfoutput>
									<option value="#variables.time#:00"<cfif variables.time EQ 8> selected="selected"</cfif>>#TimeFormat(CreateTime(variables.time, 00, 00), 'h:mm tt')#</option>
								</cfoutput>
							</cfloop>
						</select>
                   </div>

                    <div class="error-row error error-date0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div class="full-row highlight-date1">
                  <label for="flightcar_returndate" class="biglabel">return</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input name="flightcar_returndate" placeholder="date" type="text" id="flightcar_returndate" class=
                      "flex field-date1 date tag-date1" />
                    </div>
                    <div class="input-container">
						<select name="flightcar_returnaol" id="flightcar_returnaol" >
							<option value="A">Arrive</option>
							<option value="D" selected>Leave</option>
						</select>
                    </div>
                    <div class="input-container">
						<select name="flightcar_returntime" id="flightcar_returntime" >
							<option value="">Anytime</option>
							<option value="06:00">Early Morning</option>
							<option value="10:00">Late Morning</option>
							<option value="14:00">Afternoon</option>
							<option value="18:00">Evening</option>
							<option value="00:00">Red-eye</option>
							<cfloop from="0" to="23" index="time">
								<cfoutput>
									<option value="#variables.time#:00"<cfif variables.time EQ 8> selected="selected"</cfif>>#TimeFormat(CreateTime(variables.time, 00, 00), 'h:mm tt')#</option>
								</cfoutput>
							</cfloop>
						</select>
                   </div>

                    <div class="error-row error error-date1"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div class="full-row">
                  <label for="flightcar_pickuploc" class="biglabel">car</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input id="flightcar_pickuploc" name="flightcar_pickuploc" placeholder="airport" type="text" class=
                      " field-from0 autocomplete routelang ac_id-accar1" />
                    </div>

                    <div class="error-row error error-from0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

			<div class="options">
						 
				  <select class="field-cars" tabindex="" name="flightcar_cars" id="flightcar_cars">
					<option selected="selected" value="1">1 Car</option>
					<option value="2">2 Cars</option>
					<option value="3">3 Cars</option>
					<option value="4">4 Cars</option>
				  </select>

				  <select class="field-flight-airline" tabindex="" name="flightcar_airline" id="flightcar_airline">
					<option selected="selected" value="">All Airlines</option>
						<cfloop query="qAllAirlines">
							<cfoutput><option value="#Vendor_Code#" >#Vendor_Name#</option></cfoutput>
						</cfloop>
				  </select>
						 
				  <select class="field-flight-cabin" tabindex="" name="flightcar_cabin" id="flightcar_cabin">
					<option selected="selected" value="Y">Economy</option>
					<option value="C">Business</option>
					<option value="F">First</option>
				  </select>
				</div>
				<div class="submit-row">
				  <button class="status submit darkbookingbutton" type="submit"> Search! </button>
				</div>
			  </div>
			</form>
		  </div>
		  <div id="flighthotel" class="search-form-wrapper" style="display: none;">
			<cfoutput>
			<form action="#buildURL('search.addSearchRecord')#&Search_ID=206352" method="post" class="search-form form-flight" id="flight" name="flight">
				<input type="hidden" name="Searchtype" value="flighthotel">
				<input type="hidden" name="User_ID" id="User_ID" value="175401">
			</cfoutput>
				<div class="form-padding">
                <div class="search-logo image-flight"></div>

                <div class="error-status"></div>
				<input type="hidden" name="form" value="flight" />

                <div class="full-row">
                  <label for="flighthotel_for" class="biglabel">for</label>

                  <div class="input-row">
                    <div class="input-container">
						<select name="for" id="flighthotel_for">
							<option value="Myself">myself</option>
							<option value="guest">guest</option>
							<option value="Test1">test1</option>
							<option value="Test2">test2</option>
						</select>
                    </div>

                    <div class="error-row error error-for"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div id="flighthotel-department" class="full-row" style="display:none">
                  <label for="flighthotel_dept" class="biglabel">dept.</label>

                  <div class="input-row">
                    <div class="input-container">
						<select name="dept" id="flighthotel_dept">
							<option value="D1">Department 1</option>
							<option value="D2">Department 2</option>
							<option value="D3">Department 3</option>
							<option value="D4">Department 4</option>
						</select>
                    </div>

                    <div class="error-row error error-for"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div class="full-row">
                  <label for="flighthotel_fromlocation" class="biglabel">from</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input id="flighthotel_fromlocation" name="flighthotel_fromlocation" placeholder="place or airport" type="text" class="field-from0" />
                    </div>

                    <div class="error-row error error-from0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div class="full-row">
                  <label for="flighthotel_tolocation" class="biglabel">to</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input id="flighthotel_tolocation" name="flighthotel_tolocation" placeholder="place or airport" type="text" class="field-to0" />
                    </div>

                    <div class="error-row error error-to0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div class="full-row highlight-date0">
                  <label for="flighthotel_departdate" class="biglabel">depart</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input name="flighthotel_departdate" placeholder="date" type="text" id=
                      "flighthotel_departdate" class=
                      "flex field-date0 date tag-date0" />
                    </div>
                    <div class="input-container">
						<select name="flighthotel_departaol" id="flighthotel_departaol" >
							<option value="A" selected>Arrive</option>
							<option value="D">Leave</option>
						</select>
                    </div>
                    <div class="input-container">
						<select name="flighthotel_departtime" id="flighthotel_departtime" >
							<option value="">Anytime</option>
							<option value="06:00">Early Morning</option>
							<option value="10:00">Late Morning</option>
							<option value="14:00">Afternoon</option>
							<option value="18:00">Evening</option>
							<option value="00:00">Red-eye</option>
							<cfloop from="0" to="23" index="time">
								<cfoutput>
									<option value="#variables.time#:00"<cfif variables.time EQ 8> selected="selected"</cfif>>#TimeFormat(CreateTime(variables.time, 00, 00), 'h:mm tt')#</option>
								</cfoutput>
							</cfloop>
						</select>
                   </div>

                    <div class="error-row error error-date0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div class="full-row highlight-date1">
                  <label for="flighthotel_returndate" class="biglabel">return</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input name="flighthotel_returndate" placeholder="date" type="text" id="flighthotel_returndate" class=
                      "flex field-date1 date tag-date1" />
                    </div>
                    <div class="input-container">
						<select name="flighthotel_returnaol" id="flighthotel_returnaol" >
							<option value="A">Arrive</option>
							<option value="D" selected>Leave</option>
						</select>
                    </div>
                    <div class="input-container">
						<select name="flighthotel_returntime" id="flighthotel_returntime" >
							<option value="">Anytime</option>
							<option value="06:00">Early Morning</option>
							<option value="10:00">Late Morning</option>
							<option value="14:00">Afternoon</option>
							<option value="18:00">Evening</option>
							<option value="00:00">Red-eye</option>
							<cfloop from="0" to="23" index="time">
								<cfoutput>
									<option value="#variables.time#:00"<cfif variables.time EQ 8> selected="selected"</cfif>>#TimeFormat(CreateTime(variables.time, 00, 00), 'h:mm tt')#</option>
								</cfoutput>
							</cfloop>
						</select>
                   </div>

                    <div class="error-row error error-date1"></div>
                  </div>

                  <div class="clear"></div>
                </div>
				<div class="hoteloptions">
				  <select class="hotel_radius" tabindex="" name="flighthotel_radius" id="flighthotel_radius">
					<option value="1">in 1 mile of</option>
					<option value="2">in 2 miles of</option>
					<option selected="selected" value="5">in 5 miles of</option>
					<option value="10">in 10 miles of</option>
					<option value="15">in 15 miles of</option>
					<option value="20">in 20 miles of</option>
					<option value="25">in 25 miles of</option>
				  </select>
				  <div class="area-buttons">
					<div id="hotelairport" class="small-button segmented-first selected">Address/Airport</div>
					<div id="hotelvenue" class="small-button segmented-last">Office/Venues</div>
				  </div>
				</div>

                <div class="full-row">
                  <label for="flighthotel_location" class="biglabel">hotel</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input id="flighthotel_location" name="flighthotel_location" placeholder="address, landmark, or airport" type="text" class=
                      " field-from0 autocomplete routelang ac_id-achot1" />
                    </div>

                    <div class="error-row error error-from0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

			<div class="options">
						 
				  <select class="field-flight-cabin" tabindex="" name="flighthotel_rooms" id="flighthotel_rooms">
					<option selected="selected" value="1">1 Room</option>
					<option value="2">2 Rooms</option>
					<option value="3">3 Rooms</option>
				  </select>

				  <select class="field-flight-airline" tabindex="" name="flighthotel_airline" id="flighthotel_airline">
					<option selected="selected" value="">All Airlines</option>
						<cfloop query="qAllAirlines">
							<cfoutput><option value="#Vendor_Code#" >#Vendor_Name#</option></cfoutput>
						</cfloop>
				  </select>
						 
				  <select class="field-flight-cabin" tabindex="" name="flighthotel_cabin" id="flighthotel_cabin">
					<option selected="selected" value="Y">Economy</option>
					<option value="C">Business</option>
					<option value="F">First</option>
				  </select>
				</div>
				<div class="submit-row">
				  <button class="status submit darkbookingbutton" type="submit"> Search! </button>
				</div>
			  </div>
			</form>
		  </div>
		  <div id="flighthotelcar" class="search-form-wrapper" style="display: none;">
			<cfoutput>
			<form action="#buildURL('search.addSearchRecord')#&Search_ID=206352" method="post" class="search-form form-flight" id="flight" name="flight">
				<input type="hidden" name="Searchtype" value="flighthotelcar">
				<input type="hidden" name="User_ID" id="User_ID" value="175401">
			</cfoutput>
				<div class="form-padding">
                <div class="search-logo image-flight"></div>

                <div class="error-status"></div>
				<input type="hidden" name="form" value="flight" />

                <div class="full-row">
                  <label for="flighthotelcar_for" class="biglabel">for</label>

                  <div class="input-row">
                    <div class="input-container">
						<select name="for" id="flighthotelcar_for">
							<option value="Myself">myself</option>
							<option value="guest">guest</option>
							<option value="Test1">test1</option>
							<option value="Test2">test2</option>
						</select>
                    </div>

                    <div class="error-row error error-for"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div id="flighthotelcar-department" class="full-row" style="display:none">
                  <label for="flighthotelcar_dept" class="biglabel">dept.</label>

                  <div class="input-row">
                    <div class="input-container">
						<select name="dept" id="flighthotelcar_dept">
							<option value="D1">Department 1</option>
							<option value="D2">Department 2</option>
							<option value="D3">Department 3</option>
							<option value="D4">Department 4</option>
						</select>
                    </div>

                    <div class="error-row error error-for"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div class="full-row">
                  <label for="flighthotelcar_fromlocation" class="biglabel">from</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input id="flighthotelcar_fromlocation" name="flighthotelcar_fromlocation" placeholder="place or airport" type="text" class="field-from0" />
                    </div>

                    <div class="error-row error error-from0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div class="full-row">
                  <label for="flighthotelcar_tolocation" class="biglabel">to</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input id="flighthotelcar_tolocation" name="flighthotelcar_tolocation" placeholder="place or airport" type="text" class="field-to0" />
                    </div>

                    <div class="error-row error error-to0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div class="full-row highlight-date0">
                  <label for="flighthotelcar_departdate" class="biglabel">depart</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input name="flighthotelcar_departdate" placeholder="date" type="text" id=
                      "flighthotelcar_departdate" class=
                      "flex field-date0 date tag-date0" />
                    </div>
                    <div class="input-container">
						<select name="flighthotelcar_departaol" id="flighthotelcar_departaol" >
							<option value="A" selected>Arrive</option>
							<option value="D">Leave</option>
						</select>
                    </div>
                    <div class="input-container">
						<select name="flighthotelcar_departtime" id="flighthotelcar_departtime" >
							<option value="">Anytime</option>
							<option value="06:00">Early Morning</option>
							<option value="10:00">Late Morning</option>
							<option value="14:00">Afternoon</option>
							<option value="18:00">Evening</option>
							<option value="00:00">Red-eye</option>
							<cfloop from="0" to="23" index="time">
								<cfoutput>
									<option value="#variables.time#:00"<cfif variables.time EQ 8> selected="selected"</cfif>>#TimeFormat(CreateTime(variables.time, 00, 00), 'h:mm tt')#</option>
								</cfoutput>
							</cfloop>
						</select>
                   </div>

                    <div class="error-row error error-date0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div class="full-row highlight-date1">
                  <label for="flighthotelcar_returndate" class="biglabel">return</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input name="flighthotelcar_returndate" placeholder="date" type="text" id="flighthotelcar_returndate" class=
                      "flex field-date1 date tag-date1" />
                    </div>
                    <div class="input-container">
						<select name="flighthotelcar_returnaol" id="flighthotelcar_returnaol" >
							<option value="A">Arrive</option>
							<option value="D" selected>Leave</option>
						</select>
                    </div>
                    <div class="input-container">
						<select name="flighthotelcar_returntime" id="flighthotelcar_returntime" >
							<option value="">Anytime</option>
							<option value="06:00">Early Morning</option>
							<option value="10:00">Late Morning</option>
							<option value="14:00">Afternoon</option>
							<option value="18:00">Evening</option>
							<option value="00:00">Red-eye</option>
							<cfloop from="0" to="23" index="time">
								<cfoutput>
									<option value="#variables.time#:00"<cfif variables.time EQ 8> selected="selected"</cfif>>#TimeFormat(CreateTime(variables.time, 00, 00), 'h:mm tt')#</option>
								</cfoutput>
							</cfloop>
						</select>
                   </div>

                    <div class="error-row error error-date1"></div>
                  </div>

                  <div class="clear"></div>
                </div>
				<div class="hoteloptions">
				  <select class="hotel_radius" tabindex="" name="flighthotelcar_radius" id="flighthotelcar_radius">
					<option value="1">in 1 mile of</option>
					<option value="2">in 2 miles of</option>
					<option selected="selected" value="5">in 5 miles of</option>
					<option value="10">in 10 miles of</option>
					<option value="15">in 15 miles of</option>
					<option value="20">in 20 miles of</option>
					<option value="25">in 25 miles of</option>
				  </select>
				  <div class="area-buttons">
					<div id="hotelairport" class="small-button segmented-first selected">Address/Airport</div>
					<div id="hotelvenue" class="small-button segmented-last">Office/Venues</div>
				  </div>
				</div>

                <div class="full-row">
                  <label for="flighthotelcar_location" class="biglabel">hotel</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input id="flighthotelcar_location" name="flighthotelcar_location" placeholder="address, landmark, or airport" type="text" class=
                      " field-from0 autocomplete routelang ac_id-achot1" />
                    </div>

                    <div class="error-row error error-from0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

                <div class="full-row">
                  <label for="flighthotelcar_pickuploc" class="biglabel">car</label>

                  <div class="input-row">
                    <div class="input-container">
                      <input id="flighthotelcar_pickuploc" name="flighthotelcar_pickuploc" placeholder="airport" type="text" class=
                      " field-from0 autocomplete routelang ac_id-accar1" />
                    </div>

                    <div class="error-row error error-from0"></div>
                  </div>

                  <div class="clear"></div>
                </div>

			<div class="options">
						 
				  <select class="field-flight-cabin" tabindex="" name="flighthotelcar_rooms" id="flighthotelcar_rooms">
					<option selected="selected" value="1">1 Room</option>
					<option value="2">2 Rooms</option>
					<option value="3">3 Rooms</option>
				  </select>

				  <select class="field-flight-airline" tabindex="" name="flighthotelcar_airline" id="flighthotelcar_airline">
					<option selected="selected" value="">All Airlines</option>
						<cfloop query="qAllAirlines">
							<cfoutput><option value="#Vendor_Code#" >#Vendor_Name#</option></cfoutput>
						</cfloop>
				  </select>
						 
				  <select class="field-flight-cabin" tabindex="" name="flighthotelcar_cabin" id="flighthotelcar_cabin">
					<option selected="selected" value="Y">Economy</option>
					<option value="C">Business</option>
					<option value="F">First</option>
				  </select>
						 
				  <select class="field-cars" tabindex="" name="flighthotelcar_cars" id="flighthotelcar_cars">
					<option selected="selected" value="1">1 Car</option>
					<option value="2">2 Cars</option>
					<option value="3">3 Cars</option>
					<option value="4">4 Cars</option>
				  </select>
				</div>
				<div class="submit-row">
				  <button class="status submit darkbookingbutton" type="submit"> Search! </button>
				</div>
			  </div>
			</form>
		  </div>
		</div>
	</body>
</html>
